# -*- encoding : utf-8 -*-
class TipoLista < ActiveRecord::Base
  self.table_name = :tipo_lista
  #default_scope where('tipo_lista.entidade_id in (?)',User.usuario_atual.entidade_ids)

  has_attached_file :arquivo,:url => '/arquivos/:filename'
  validates_attachment_content_type :arquivo, :content_type =>['text/plain']
  #validates_attachment_presence(:arquivo)


  has_many :listas,:foreign_key=>"tipo_lista_id",:dependent=>:destroy
  belongs_to :entidade
  scope :busca, lambda { |q| where("nome like ?" ,"%#{q}%") }
  has_many :funcionarios,:through=>:listas,:source=>:funcionario
  has_many :pessoas,:through=>:listas,:source=>:pessoa
  has_and_belongs_to_many :roles

  # has_and_belongs_to_many :naturezas,:join_table=>:naturezas_listas
  validates_uniqueness_of :nome,:scope=>:tipo_objeto
  scope :pessoal, -> { where("tipo_objeto=?","Pessoa")}
  scope :pessoal_filtro, lambda {|ids| where("tipo_objeto=? and id not in (?)","Pessoa",ids)}
  scope :funcional, -> { where("tipo_objeto=?","Funcionário")}
  scope :ativa, -> { where("ativo = ?",true)}
  scope :privadas, -> { where("privada = ?",true)}
  scope :publicas, -> { where("privada = ?",false)}

  def possui_funcionarios?
    if self.funcionarios.size>0 or self.pessoas.size>0
      return true
    else
      return false
    end
  end

  def total_financeiros
    valor_total = 0.0
    pessoas = self.pessoas.all
    pessoas.each do |p|
      if !p.funcionarios.nil?
        p.funcionarios.all.each do |v|
          valor_total+=v.nivel.vencimento.valor*2
        end
      end
    end
    return valor_total
  end

end
