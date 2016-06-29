# -*- encoding : utf-8 -*-
require "barby/barcode/code_39"
require "barby/outputter/png_outputter"
class Lotacao < ActiveRecord::Base
  self.table_name = "lotacaos"
  #attr_accessible *column_names
  #attr_accessible :destino_nome
  #audited :associated_with => :funcionario
  validates_uniqueness_of :orgao_id,:scope=>[:funcionario_id,:ativo],:message=>"Funcionário precisa ser devolvido para ser lotado novamente.",:on=>:create,:if=>Proc.new{|l|l.tipo_lotacao=="SUMARIA ESPECIAL" or l.tipo_lotacao=="ESPECIAL"}
  validates_uniqueness_of :destino_id,:scope=>[:funcionario_id,:destino_type,:ativo],:message=>"Já lotado neste destino"

  validates_presence_of :usuario_id
  validates_presence_of :natureza,:if=>Proc.new{|l|l.tipo_lotacao=="REGULAR" or l.tipo_lotacao=="SUMARIA"},:on=>:create
  #validates_presence_of :funcionario_id
  validates_presence_of :tipo_lotacao
  validates_presence_of :destino_id,:message=>"É necessário que o destino seja válido"
  validates :motivo, :length => {:maximum => 230, :message => "Observaçao/Motivo até 230 caracteres" }
  validates_date :data_lotacao,:message=>"Data da Lotação Inválida"
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
  has_many :lot_observacoes, :dependent => :destroy
  has_one :contrato,:dependent=>:destroy
  has_one :pessoa,:through=>:funcionario
  before_save :funcionario_v
  validate :validar_complementar
  def funcionario_v
    if self.funcionario_id.blank?
      self.errors.add(:funcionario_id,"Funcionario não está presente")
    end
  end

  def validar_complementar
    if self.natureza!="Complementar Carga Horária" and self.funcionario.lotacoes.ativas.where(:destino_type=>"Escola").any?
      self.errors.add(:natureza,"Apenas Lotações complementares em escolas são permitidas quando o funcionário já está lotado")
    end
  end

  scope :em_aberto, -> { where("finalizada = ?",false)}
  scope :finalizadas, -> { where("finalizada = ?",true)}
  scope :atual,-> { where("finalizada = ? and ativo = ? and complementar = ?",true,true,false)}
  scope :complementares,-> { where("finalizada = ? and ativo = ? and complementar = ?",true,true,true)}
  def self.inativas
    Lotacao.where("ativo = false")
  end
  #scope :inativa, -> { where("ativo = ?",false)}
  scope :ativas, -> { where("lotacaos.ativo = ? and (lotacaos.natureza not like ? or lotacaos.natureza is null)",true,"Complementar Carga Horária")}
  scope :complementares_ativas, -> { where("ativo = ? and natureza = ?",true,"Complementar Carga Horária")}
  # scope :canceladas, -> { joins(:statuses).where("lotacoes.status = 'CANCELADO'")}
  scope :canceladas, -> {joins(:status).where("statuses.status = 'CANCELADO'")}
  scope :confirmada_fechada, -> { where("finalizada = ? and ativo=?",true,true)}
  scope :verifica, lambda {|func,escola| where("funcionario_id = ? and escola_id=?",func,escola)}
  scope :pro_labore, -> { where("tipo_lotacao = ?","PROLABORE")}
  scope :sumaria, -> { where("tipo_lotacao = ?","SUMARIA")}
  scope :sumaria_especial, -> { where("tipo_lotacao = ?","SUMARIA ESPECIAL")}
  scope :comissionada,-> { where("tipo_lotacao = ?","COMISSÃO")}
  scope :especial, -> { where("tipo_lotacao = ?","ESPECIAL")}
  scope :regular, -> { where("tipo_lotacao = ?","REGULAR")}
  scope :a_convalidar, -> { where(:convalidada=>false)}
  scope :da_escola,lambda{|esc|where("escola_id = ?",esc)}
  scope :em_escolas_urbanas, -> { where("destino_id in (?) and destino_type = 'Escola'",Escola.joins(:municipio).where("municipios.nome = 'Macapá' or municipios.nome = 'Santana' and zona = 'Urbana'"))}
  scope :interiorizacao_urbana, -> { joins(:funcionario).where("funcionarios.interiorizacao = true and destino_type = 'Escola' and lotacaos.destino_id in (?)",Escola.joins(:municipio).where("municipios.nome = 'Macapá' or municipios.nome = 'Santana' and zona = 'Urbana'"))}
  scope :em_escolas_rurais, -> { where("destino_id in (?) and destino_type = 'Escola'",Escola.joins(:municipio).where("municipios.nome = 'Macapá' or municipios.nome = 'Santana' and zona = 'Rural'"))}
  scope :em_prefeituras, -> { where("destino_id in (?) and destino_type = 'Orgao'",Orgao.where("nome ilike 'Prefeitura%'"))}
  scope :em_setoriais, -> { where("destino_type = 'Departamento'")}
  scope :com_interiorizacao, -> { joins(:funcionario).where("funcionarios.interiorizacao = true")}
  scope :de_efetivos, -> {joins(:funcionario).where("funcionarios.categoria_id = 1 or funcionarios.categoria_id = 5 or funcionarios.categoria_id = 6 or funcionarios.categoria_id = 15")}
  scope :de_professores, -> {joins(:funcionario).where("funcionarios.cargo_id = 98")}
  scope :state_vazio, -> { where("state IS NOT NULL")}
  attr_accessor :destino_nome
  #delegate :nome,:to=>:destino
  after_create :codigo
  after_create :lotacao_regular
  #before_create :data
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
    proc.send(:instance_variable_set, :@readonly, false)
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
    proc.send(:instance_variable_set, :@readonly, false)
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
    proc2.send(:instance_variable_set, :@readonly, false)
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
    proc2.send(:instance_variable_set, :@readonly, false)
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
      self.data_devolucao = Time.now
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
  #         return "#{lotacao.escola.nome}/#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
  #         return "#{lotacao.departamento.nome.upcase}/#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL"  and !lotacao.escola.nil? and lotacao.departamento.nil?
  #         return "#{lotacao.escola.nome}/#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="COMISSÃO" and !lotacao.departamento.nil? and lotacao.escola.nil?
  #         return "#{lotacao.departamento.sigla}/#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="COMISSÃO" and !lotacao.escola.nil? and lotacao.departamento.nil?
  #         return "#{lotacao.escola.nome}/#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
  #         return "#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
  #         return "#{lotacao.orgao.sigla}"
  #     elsif lotacao.tipo_lotacao=="SUMARIA" or lotacao.tipo_lotacao=="REGULAR" or lotacao.tipo_lotacao=="PROLABORE"
  #         return "#{lotacao.escola.nome}"
  #     elsif lotacao.escola.nil? and lotacao.orgao.nil? and lotacao.departamento.nil?
  #         return "LOTAÇÃO INVÁLIDA"
  #     end
  # end
  # end

  def pontualidade_apresentacao
    limite = self.data_lotacao+3.day
    if self.data_confirmacao < limite
      return "Apresentaçao feita dentro do prazo"
    else
      tempo = self.data_confirmacao - limite
      if tempo == 1
        return "Apresentaçao feita fora do prazo (#{tempo.to_i} dia)"
      elsif tempo > 1
        return "Apresentaçao feita fora do prazo (#{tempo.to_i} dias)"
      end
    end
  end

  def status_para_state
    if self.status.last.status == 'ENCAMINHADO' or self.status.last.status == 'EM TRÂNSITO'
      self.encaminhar
      self.lot_observacoes.create(:item=>'Encaminhado',:descricao=>"Destino: #{self.destino.nome}",:responsavel=>"#{self.usuario.name}")
    elsif self.status.last.status == 'CANCELADO'
      self.cancelar
      self.lot_observacoes.create(:item=>'Cancelado',:descricao=>"Motivo: #{self.motivo}",:responsavel=>"#{self.usuario.name}")
    elsif self.status.last.status == 'LOTADO'
      self.confirmar
      self.lot_observacoes.create(:item=>'Lotado',:descricao=>"",:responsavel=>"#{self.usuario.name}")
    elsif self.status.last.status == 'À DISPOSIÇÃO DO NUPES' or self.status.last.status == 'NÃO LOTADO'
      self.devolver
      self.lot_observacoes.create(:item=>'Devolvido',:descricao=>"Motivo: #{self.motivo}",:responsavel=>"#{self.usuario.name}")
    end
  end

  state_machine :state, :initial => nil do
    event :encaminhar do
      transition any => :encaminhado
    end
    event :cancelar do
      # transition :encaminhado => :cancelado
      transition any => :cancelado
    end
    event :confirmar do
      # transition :encaminhado => :confirmado
      transition any => :confirmado
    end
    event :devolver do
      # transition :confirmado => :devolvido
      transition any => :devolvido
    end
    after_transition nil => :encaminhado do |lotacao, transition|
      # lotacao.lot_observacoes.create(:item=>'Encaminhado',:descricao=>"Destino: #{lotacao.destino.nome}",:responsavel=>"#{lotacao.usuario.name}")
    end
    after_transition :confirmado => :devolvido do |lotacao, transition|

    end
  end

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
        lotacoes = Lotacao.confirmada_fechada.ativas.find :all,:conditions=>["funcionario_id = ? and id<>?",self.funcionario_id,self.id]
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
