class AddContratoIdToLotacaos < ActiveRecord::Migration
  def change
    add_column :lotacaos, :contrato_id, :integer
  end
end
