# -*- encoding : utf-8 -*-
class Departamento < ActiveRecord::Base
  #default_scope where('entidade_id in (?)',User.usuario_atual.entidade_ids)
  belongs_to :orgao
  belongs_to :tipo_destino
  belongs_to :entidade
  has_many :comissionados
  has_many :lotacoes,:as=>:destino
  has_many :lotacoes_filhos,:through=>:funcionarios_filhos,:source=>:lotacoes,:uniq=>true
  has_many :funcionarios,:through=>:lotacoes,:source=>"funcionario"
  has_many :funcionarios_encaminhados,:through=>:lotacoes,:class_name=>"Funcionario",:source=>"funcionario"
  has_many :funcionarios_filhos,:through=>:departamentos_filhos,:source=>:funcionarios, :uniq => true
  has_one :responsavel,:through=>:comissionados,:source=>:funcionario
  has_many :funcionarios_comissionados,:through=>:comissionados,:source=>'funcionario'
  belongs_to :departamento_pai,:class_name=>"Departamento",:foreign_key => "pai_id"
  has_many :departamentos_filhos,:class_name=>"Departamento",:foreign_key => "pai_id"
  scope :do_orgao, lambda {|id|where("departamentos.orgao_id = ?",id) }
  belongs_to :municipio
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
