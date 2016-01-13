# -*- encoding : utf-8 -*-
class RecadCargo < ActiveRecord::Base
  self.table_name =  :recad_cargos
  belongs_to :recad_pessoa

end
