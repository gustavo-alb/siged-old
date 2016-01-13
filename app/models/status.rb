# -*- encoding : utf-8 -*-
class Status < ActiveRecord::Base
  self.table_name =  :statuses
  belongs_to :processo
end
