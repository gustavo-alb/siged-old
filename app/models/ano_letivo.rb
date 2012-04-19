class AnoLetivo < ActiveRecord::Base
	extend FriendlyId
    friendly_id :ano, :use=> :slugged
    validates_presence_of :ano
    has_many :turmas

   

   
end
