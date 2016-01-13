# -*- encoding : utf-8 -*-
class Role < ActiveRecord::Base

  scope :busca, lambda { |q| where("name like ?" ,"%#{q}%") }
  has_and_belongs_to_many :users,:join_table=>"roles_users"
  has_and_belongs_to_many :listas,:class_name=>"TipoLista",:join_table=>:roles_tipo_listas

  belongs_to :entidade


end
