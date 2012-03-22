class Curriculo < ActiveRecord::Base
	belongs_to :matriz
	belongs_to :serie
	belongs_to :disciplina
	belongs_to :fator,:class_name=>"FatorLotacao"
	#has_many :fator_lotacoes,:class_name=>"FatorLotacao"
	scope :da_serie,lambda{|serie| where("serie_id=?",serie)}
	scope :da_disciplina,lambda{|dis| where("disciplina_id=?",dis)}
	scope :da_matriz,lambda{|mat| where("matriz_id=?",mat)}

end
