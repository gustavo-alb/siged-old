# -*- encoding : utf-8 -*-
class Departamento < ActiveRecord::Base
  #default_scope where('entidade_id in (?)',User.usuario_atual.entidade_ids)
  belongs_to :orgao
  belongs_to :tipo_destino
  belongs_to :entidade
  has_many :comissionados,:conditions=>["ativo = ?",true]
  has_many :lotacoes,:conditions=>["lotacaos.finalizada = ? and lotacaos.ativo = ? and lotacaos.complementar = ?",true,true,false],:as=>:destino
  has_many :funcionarios,:through=>:lotacoes,:source=>"funcionario"
  has_many :funcionarios_encaminhados,:through=>:lotacoes,:conditions=>["lotacaos.ativo = ? and lotacaos. finalizada = ?",true,false],:class_name=>"Funcionario",:source=>"funcionario"
  has_one :responsavel,:through=>:comissionados,:conditions=>["comissionados.tipo = ?","CHEFIA"],:source=>:funcionario
  has_many :funcionarios_comissionados,:through=>:comissionados,:conditions=>["comissionados.ativo = true"],:source=>'funcionario'
  belongs_to :departamento_pai,:class_name=>"Departamento",:foreign_key => "pai_id"
  has_many :departamentos_filhos,:class_name=>"Departamento",:foreign_key => "pai_id",:order => 'sigla ASC'
  scope :do_orgao, lambda {|id|where("departamentos.orgao_id = ?",id) }
  scope :busca, lambda { |q| where("sigla ilike ? or nome ilike ?" ,"%#{q}%","%#{q}%") }
  attr_accessor :pai_nome

  validates_uniqueness_of :nome,:scope=>[:nome,:sigla]

  before_save :setar_nil

  def municipio_nome
    return "MACAPA"
  end
  private

  def setar_nil
    if self.hierarquia==""
      self.hierarquia=nil
    end
  end
end
