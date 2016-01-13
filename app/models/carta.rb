# -*- encoding : utf-8 -*-
class Carta < ActiveRecord::Base
  self.table_name = "carta"
  #has_attached_file :carta, :styles { :thumb => "100×200#",:mini=>"17x17#" }
end
