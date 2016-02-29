class Contrato < ActiveRecord::Base
  attr_accessible :funcionario_id, :lotacao_id, :numero, :salario
  belongs_to :funcionario
  belongs_to :lotacao
end
