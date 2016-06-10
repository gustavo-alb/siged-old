class LotObservacao < ActiveRecord::Base
  attr_accessible :descricao, :item, :lotacao_id, :responsavel, :created_at
  belongs_to :lotacao
end
