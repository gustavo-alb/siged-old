# -*- encoding : utf-8 -*-
class TipoAdministracao < ActiveRecord::Base
  self.table_name =  :tipo_administracaos
  has_many :orgaos
end
