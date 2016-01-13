# -*- encoding : utf-8 -*-
class BoletimFuncional < ActiveRecord::Base
  self.table_name = "boletins_funcionais"
  belongs_to :funcionario
  belongs_to :entidade
  scope :do_func, lambda {|id|where("funcionario_id = ?",id) }
end
