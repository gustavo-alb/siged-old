class Status < ActiveRecord::Base
  set_table_name :statuses
  belongs_to :processo
end
