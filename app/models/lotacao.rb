# -*- encoding : utf-8 -*-
require "barby/barcode/code_39"
require "barby/outputter/png_outputter"
class Lotacao < ActiveRecord::Base
  set_table_name :lotacaos
  #escola_id sempre nil em lotacao especial
  validates_uniqueness_of :orgao_id,:scope=>[:funcionario_id,:ativo],:message=>"Funcionário precisa ser devolvido para ser lotado novamente.",:on=>:create
  validates_presence_of :usuario_id,:funcionario_id,:destino_id
  validates :motivo, :length => {:maximum => 230, :message => "Observaçao/Motivo até 230 caracteres" }
  belongs_to :funcionario,:class_name=>'Funcionario'
  belongs_to :orgao
  belongs_to :entidade
  belongs_to :disciplina_atuacao,:class_name=>"DisciplinaContratacao"
  belongs_to :usuario,:class_name=>"User"
  belongs_to :ambiente
  belongs_to :destino ,:polymorphic=>true
  has_many :processos,:dependent=>:destroy
  has_many :pontos
  has_many :todos_processos,:class_name=>"Processo"
  has_many :status,:class_name=>"Status",:through=>:processos,:source=>"status"
  has_many :especificacoes,:class_name=>"EspecificarLotacao",:dependent => :destroy
  
  scope :em_aberto, where("finalizada = ?",false)
  scope :finalizada, where("finalizada = ?",true)
  scope :atual,where("finalizada = ? and ativo = ? and complementar = ?",true,true,false)
  scope :complementares,where("finalizada = ? and ativo = ? and complementar = ?",true,true,true)
  scope :ativo, where("ativo = ?",true)
  scope :inativa, where("ativo = ?",false)
  scope :confirmada_fechada, where("finalizada = ? and ativo=?",true,true)
  scope :verifica, lambda {|func,escola| where("funcionario_id = ? and escola_id=?",func,escola)}
  scope :pro_labore, where("tipo_lotacao = ?","PROLABORE")
  scope :sumaria, where("tipo_lotacao = ?","SUMARIA")
  scope :sumaria_especial, where("tipo_lotacao = ?","SUMARIA ESPECIAL")
  scope :comissionada,where("tipo_lotacao = ?","COMISSÃO")
  scope :especial, where("tipo_lotacao = ?","ESPECIAL")
  scope :regular, where("tipo_lotacao = ?","REGULAR")
  scope :a_convalidar, where(:convalidada=>false)
  scope :da_escola,lambda{|esc|where("escola_id = ?",esc)}
  attr_accessor :destino_nome
  after_create :codigo
  after_create :lotacao_regular
  before_create :data
  # validate_on_create do |lotacao|
  #   if self.tipo_lotacao=="ESPECIAL" or self.tipo_lotacao=="SUMARIA ESPECIAL" and self.motivo.blank?
  #     lotacao.errors.add_to_base("Lotações tendo um departamento como destino necessitam de um motivo.")
  #   end
  # end

  def check_ativo
   if self.ativo
     return true
   else
     return false
   end
 end


 def confirma_lotacao
   proc = self.processos.em_aberto.encaminhado.last
   proc.finalizado = true
   proc.data_finalizado = Date.today
   if proc.save!
    self.finalizada = true
    self.data_confirmacao = Date.today
    self.save
    status = proc.status.new
    status.status = 'LOTADO'
    status.save
  else
    "Não foi possível gerar o processo"
  end
end

def desconfirmar_lotacao
    proc = self.processos.last
   proc.finalizado = false
   proc.data_finalizado = nil
   if proc.save!
    self.finalizada = false
    self.data_confirmacao = nil
    self.save
    status = proc.status.last.destroy
  else
    "Não foi possível gerar o processo"
  end
end



def cancela_lotacao(motivo=self.motivo)
 proc = self.processos.em_aberto.encaminhado.last
 self.finalizada = true
 self.ativo = false
 self.save
 proc2 = proc.clone
 proc2.finalizado = true
 proc2.data_finalizado = Time.now
 proc2.observacao = motivo
 proc2.natureza="CANCELAMENTO LOTAÇÃO"
 proc2.processo="CN#{proc2.processo}"
 proc2.tipo="CANCELAMENTO"
 if proc2.save
   self.ativo = false
   self.save
   self.finalizada = true
   status = proc2.status.new
   status.status = 'CANCELADO'
   status.save
 else
  "Não foi possível gerar o processo"
end


end

def devolve_funcionario(motivo=self.motivo)
 proc = self.processos.finalizado.last
 proc2 = proc.clone
 proc2.data_finalizado = Time.now
 proc2.observacao = motivo
 proc2.natureza="DEVOLUÇÃO"
 proc2.processo="DV#{proc2.processo}"
 proc2.tipo="DEVOLUÇÃO"
 self.ativo = false
 self.save!
 if proc2.save!
   if self.funcionario.lotacoes_atuais.include?(self) and !self.funcionario.lotacoes.complementares.none?
     self.funcionario.lotacoes.complementares.order("created_at asc").first.update_attributes(:complementar=>false)
   end
   self.ativo = false
   self.especificacoes.delete_all
   self.save
   status = proc2.status.new
   status.status = 'À DISPOSIÇÃO DO NUPES'
   status.save
 else
  "Não foi possível gerar o processo"
end
end


def codigo
  funcionario = self.funcionario
  codfuncionario = sprintf '%07d',funcionario.id
  codlotacao = sprintf '%07d',self.id
  codigo = codfuncionario+codlotacao
  self.codigo_barra = codigo
  self.save
  return codigo
end

def img_codigo
  codigo = self.codigo
  img = Barby::Code39.new(codigo).to_png(:height=>90,:margin=>0)
  return img
end

def data
  self.data_lotacao = Date.today
  if self.tipo_lotacao=="SUMARIA" or self.tipo_lotacao=="SUMARIA ESPECIAL"
    self.data_confirmacao = Date.today
  end
end

# def destino
#   lotacao = self
#  if lotacao
#     if lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
#         return "#{lotacao.departamento.nome.upcase}/#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.escola.nil?
#         return "#{lotacao.escola.nome_da_escola}/#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
#         return "#{lotacao.departamento.nome.upcase}/#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL"  and !lotacao.escola.nil? and lotacao.departamento.nil?
#         return "#{lotacao.escola.nome_da_escola}/#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="COMISSÃO" and !lotacao.departamento.nil? and lotacao.escola.nil?
#         return "#{lotacao.departamento.sigla}/#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="COMISSÃO" and !lotacao.escola.nil? and lotacao.departamento.nil?
#         return "#{lotacao.escola.nome_da_escola}/#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
#         return "#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
#         return "#{lotacao.orgao.sigla}"
#     elsif lotacao.tipo_lotacao=="SUMARIA" or lotacao.tipo_lotacao=="REGULAR" or lotacao.tipo_lotacao=="PROLABORE"
#         return "#{lotacao.escola.nome_da_escola}"
#     elsif lotacao.escola.nil? and lotacao.orgao.nil? and lotacao.departamento.nil?
#         return "LOTAÇÃO INVÁLIDA"
#     end
# end
# end

# state_machine :initial => :a_confirmar do

#   event :confirmar do
#     transition :a_confirmar => :lotado
#   end
#   event :devolver do
#     transition :lotado => :a_disposicao
#   end
#   event :cancelar do
#     transition :a_confirmar => :a_disposicao
#   end
# end
private
def lotacao_regular
  #self.img_codigo
  self.entidade_id = self.funcionario.entidade_id
  self.codigo_barra = self.codigo
  #self.data_lotacao = Date.today
  #self.save!
  processo = Processo.new
  processo.entidade_id = self.entidade_id
  processo.tipo="LOTAÇÃO"
  if self.tipo_lotacao=="PROLABORE"
    processo.natureza="PRO LABORE"
  elsif self.tipo_lotacao=="REGULAR"
   processo.natureza="LOTAÇÃO REGULAR"
 elsif self.tipo_lotacao=="ESPECIAL"
   processo.natureza="LOTAÇÃO ESPECIAL"
 elsif self.tipo_lotacao=="SUMARIA"
   processo.natureza = "LOTAÇÃO SUMÁRIA"
   self.update_attributes(:finalizada=>true)
   self.save!
 elsif self.tipo_lotacao=="SUMARIA ESPECIAL"
   processo.natureza = "LOTAÇÃO SUMÁRIA ESPECIAL"
   self.update_attributes(:finalizada=>true)
   self.save!
 elsif self.tipo_lotacao=="COMISSÃO"
   processo.natureza="LOTAÇÃO COMISSIONADA"
   self.update_attributes(:finalizada=>true)
   self.save!
 end
 processo.funcionario_id = self.funcionario_id
 processo.destino_id = self.destino_id
 processo.ano_processo=Date.today.year
 processo.regencia_classe=self.regencia_de_classe
 processo.encaminhado_em=Date.today
 processo.lotacao_id=self.id
 processo.observacao = self.motivo
 if processo.save!
  num=processo.id
  cod=Num.new
  if self.tipo_lotacao=="PROLABORE"
    processo.processo="PL#{cod.numero(num)}/#{Date.today.year}"
  elsif self.tipo_lotacao=="REGULAR"
    self.orgao = self.destino.orgao
    processo.processo="LR#{cod.numero(num)}/#{Date.today.year}"
  elsif self.tipo_lotacao=="ESPECIAL"
    processo.processo="LE#{cod.numero(num)}/#{Date.today.year}"
  elsif self.tipo_lotacao=="SUMARIA" or self.tipo_lotacao=="SUMARIA ESPECIAL"
    processo.processo="LS#{cod.numero(num)}/#{Date.today.year}"
    processo.finalizado=true
  elsif self.tipo_lotacao=="COMISSÃO"
    processo.processo="LC#{cod.numero(num)}/#{Date.today.year}"
    processo.finalizado=true
  end
  status=Status.new
  status.data=Time.now
  status.processo_id=processo.id
  if self.tipo_lotacao=="SUMARIA" or self.tipo_lotacao=="SUMARIA ESPECIAL" or self.tipo_lotacao=="COMISSÃO" 
    status.status="LOTADO"
  else
    status.status="ENCAMINHADO"
  end
  if self.complementar==false
    lotacoes = Lotacao.confirmada_fechada.ativo.find :all,:conditions=>["funcionario_id = ? and id<>?",self.funcionario_id,self.id]
    lotacoes.each do |l|
      l.ativo = false
      l.save
    end
  end
  status.save
  processo.save

else
  processo.errors.add_to_base("O processo não pôde ser criado")
end

end




end

