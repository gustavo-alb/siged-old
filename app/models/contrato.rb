class Contrato < ActiveRecord::Base
  belongs_to :funcionario
  belongs_to :lotacao
  validates_uniqueness_of :funcionario_id,:scope=>[:lotacao_id]
  #audited :associated_with => :funcionario
end
