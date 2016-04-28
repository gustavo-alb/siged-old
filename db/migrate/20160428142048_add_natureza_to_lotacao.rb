class AddNaturezaToLotacao < ActiveRecord::Migration
  def change
    add_column :lotacaos, :natureza, :string
  end
end
