# -*- encoding : utf-8 -*-
class Pessoa < ActiveRecord::Base
  extend FriendlyId
  friendly_id :nome, :use=> :slugged

  #default_scope where('pessoas.entidade_id in (?)',User.usuario_atual.entidade_ids)
  validates_uniqueness_of :cpf,:on=>:create
  validates_presence_of :nome,:endereco,:sexo,:cpf,:rg,:numero,:bairro,:telefone_celular,:message=>"Não pode ficar em branco!"
  validates_uniqueness_of :nome,:scope => [:entidade_id,:cpf,:rg],:message=>"já cadastrado",:on=>:create
  #scoped_search
  has_many :listas,:dependent=>:destroy
  has_many :fotos,:dependent=>:destroy
  has_many :lotacoes,:through=>:funcionarios
  scope :busca,lambda { |q| includes(:funcionarios,:lotacoes).where("lotacaos.codigo_barra ilike ? or pessoas.cpf ilike ? or funcionarios.matricula ilike ? or rg ilike ? or nome iLIKE ?" ,"%#{q.downcase}%","%#{q}%","%#{q.downcase}%","%#{q.downcase}%","%#{q.downcase}%") }
  scope :em_aberto,  -> { where("nascimento = ?",nil)}

  scope :que_esta_na_lista,  -> { joins(:listas).where("listas.tipo_lista_id=1")}
  has_many :funcionarios,:class_name=>"Funcionario",:dependent=>:destroy
  has_many :lotacoes,:through=>:funcionarios
  accepts_nested_attributes_for :funcionarios
  belongs_to :entidade
  belongs_to :cidade
  scope :diretores,lambda {joins(:funcionarios).where("funcionarios.id in(select funcionario_id from comissionados where comissionados.tipo='DIRETORIA' and comissionados.ativo=true)")}
  scope :responsaveis,lambda {joins(:funcionarios).where("funcionarios.id in(select funcionario_id from comissionados where comissionados.tipo='CHEFIA' and comissionados.ativo=true)")}
  scope :secretarios,lambda {joins(:funcionarios).where("funcionarios.id in(select funcionario_id from comissionados where comissionados.tipo='SECRETARIA' and comissionados.ativo=true)")}
  scope :supervisores,lambda {joins(:funcionarios).where("funcionarios.id in(select funcionario_id from comissionados where comissionados.tipo='SUPERVISAO' and comissionados.ativo=true)")}
  scope :sem_lotacao,  -> { includes(:lotacoes).where(:lotacaos => { :funcionario_id => nil })}
  scope :efetivos,  -> { where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Ex-Ipesap"), Categoria.find_by_nome("Estado Antigo"), Categoria.find_by_nome("Estado Novo"),Categoria.find_by_nome("Concurso de 2012"),Categoria.find_by_nome("992")])}
  scope :mais_de_um_vinculo,  -> { joins(:funcionarios).group("pessoas.id").having("count(funcionarios.id) > ?", 1)}
  scope :sem_lotacao_com_mais_de_um_vinculo, -> { joins(:funcionarios).includes(:lotacoes).group("pessoas.id,lotacaos.id,funcionarios.id").having("count(funcionarios.id) > ? and count(lotacaos.id) = ?", 1,0)}

  has_many :formacoes,:class_name=>"Formacao",:dependent=>:destroy
  has_many :boletins,:class_name=>"BoletimPessoal",:dependent=>:destroy

  before_save :converter_cpf,:nome_upcase
  SEXO=[["Masculino","Masculino"],["Feminino","Feminino"],["Outros","Outros"]]
  UF=[["AC"],["AL"],["AM"],["AP"],["BA"],
      ["CE"],["DF"],["ES"],["GO"],["MA"],
      ["MG"],["MS"],["MT"],["PA"],["PB"],
      ["PE"],["PI"],["PR"],["RJ"],["RN"],
      ["RO"],["RR"],["RS"],["SC"],["SE"],
      ["SP"],["TO"]]

  NACION=[
    ['Brasileiro (a)'],
    ['Estrangeiro (a)']
  ]

  ESTCIV=[
    ['Solteiro (a)'],
    ['Casado (a)'],
    ['Divorciado (a)'],
    ['União Estável','Uniao Estavel']
  ]

  private
  def converter_cpf
    cpf = self.cpf
    self.cpf = cpf.to_s.gsub(".","").gsub("-","")
  end
  def nome_upcase
    self.nome = self.nome.upcase
  end

  def self.ransackable_scopes(auth_object = nil)
    [:sem_lotacao,:mais_de_um_vinculo,:sem_lotacao_com_mais_de_um_vinculo]
  end

end
