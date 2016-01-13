# -*- encoding : utf-8 -*-
class DisciplinaContratacao < ActiveRecord::Base
  #default_scope where('entidade_id in (?)',User.usuario_atual.entidade_ids)

  self.table_name = "descricao_cargos"
  scope :busca, lambda { |q| where("codigo ilike ? or nome ilike ?" ,"%#{q}%","%#{q}%") }
  belongs_to :tipo
  belongs_to :nivel_cargo
  belongs_to :entidade
  has_many :funcionarios
  has_many :lotacoes,:foreign_key=>"disciplina_atuacao_id"
  has_and_belongs_to_many :disciplinas,:class_name=>"Disciplina",:join_table => "disciplinas_habilitacoes"

  def self.find_or_create_by(attributes, &block)
    find_by_codigo(attributes) || create(attributes, &block)
  end
end
