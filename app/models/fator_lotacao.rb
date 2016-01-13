# -*- encoding : utf-8 -*-
class FatorLotacao < ActiveRecord::Base
  self.table_name = "fator_lotacaos"
  #default_scope where('especificar_lotacaos.entidade_id in (?)',User.usuario_atual.entidade_ids)

  belongs_to :especificar_lotacao
  scope :da_serie,lambda{|serie| where("serie_id=?",serie)}
  scope :da_turma,lambda{|turma| where("turma_id=?",turma)}
  validates_uniqueness_of :disciplina_id,:scope=>[:turma_id,:especificar_lotacao_id,:curriculo_id,:serie_id]
end
