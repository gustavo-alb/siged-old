# -*- encoding : utf-8 -*-
class Diretor < Funcionario
  belongs_to :escola
  scope  :sem_escola, -> {where(:escola_id=>nil)}
  has_one :usuario,:foreign_key=>'funcionario_id'

end
