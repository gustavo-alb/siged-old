# -*- encoding : utf-8 -*-
class Formacao < ActiveRecord::Base
  self.table_name = "formacaos"
  #acts_as_taggable
  #acts_as_taggable_on :nivel_formacao,:tipo_titulo,:instituicao,:habilitacao
  validates_presence_of :nivel_id,:ano_de_inicio,:status
  belongs_to :pessoa
  belongs_to :subtipo
  belongs_to :titulo
  belongs_to :nivel
  scope :da_pessoa, lambda {|id|where("pessoa_id = ?",id) }
  NIVEL=[
    ["Ensino Fundamental","Ensino Fundamental"],
    ["Ensino Médio Incompleto","Ensino Médio Incompleto"],
    ["Ensino Médio","Ensino Médio"],
    ["Ensino Profissionalizante","Ensino Profissionalizante"],
    ["Ensino Superior","Ensino Superior"],
    ["Pós-Graduação","Pós-Graduação"],
    ["Mestrado","Mestrado"],
    ["Doutorado","Doutorado"],
    ["Pós-Doutorado","Pós-Doutorado"]
  ]
  STATUS=[['Cursando'],['Concluido'],['Incompleto']]
end
