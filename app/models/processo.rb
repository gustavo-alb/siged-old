# -*- encoding : utf-8 -*-
class Processo < ActiveRecord::Base
  #default_scope where('entidade_id in (?)',User.usuario_atual.entidade_ids)
  validates_uniqueness_of :processo,:scope=>[:natureza,:funcionario_id],:on=>:create
  has_many :status,:class_name=>"Status",:dependent=>:destroy
  belongs_to :lotacao
  belongs_to :entidade
  scope :em_aberto, ->{ where("finalizado = ?",false)}
  scope :encaminhado, ->{ joins(:status).where("statuses.status = ?",'ENCAMINHADO')}
  scope :encaminhado, ->{ joins(:status).where("statuses.status = ?",'ENCAMINHADO')}
  scope :finalizado,->{ where("finalizado = ?",true)}
  scope :devolvido,->{ where("tipo=?",'DEVOLUÇÃO')}
end
