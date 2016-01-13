# -*- encoding : utf-8 -*-
class ReferenciaNivel < ActiveRecord::Base
  #default_scope where('entidade_id in (?)',User.usuario_atual.entidade_ids)
  scope :busca, lambda { |q| where("codigo ilike ? or nome ilike ?" ,"%#{q}%","%#{q}%") }
  has_many :funcionarios,:foreign_key=>"nivel_id"
  has_one :vencimento
  has_many :vencimentos,:dependent=>:destroy
  belongs_to :entidade
  validates_uniqueness_of :codigo,:scope=>[:jornada]

  JORNADA=[
    ["20 Horas Semanais",20],
    ["40 Horas Semanais",40]
  ]


end
