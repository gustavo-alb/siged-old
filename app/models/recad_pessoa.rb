# -*- encoding : utf-8 -*-
class RecadPessoa < ActiveRecord::Base
  self.table_name =  :recad_pessoas
  has_many :recad_cargos

end
