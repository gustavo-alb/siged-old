class Contrato < ActiveRecord::Base
  attr_accessible :funcionario_id, :inicio, :lotacao_id, :salario, :termino
end
