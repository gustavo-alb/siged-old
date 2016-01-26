class Cargo < ActiveRecord::Base
  belongs_to :tipo
  has_many :funcionarios
end
