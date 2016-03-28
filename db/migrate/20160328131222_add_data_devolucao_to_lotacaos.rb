
class AddDataDevolucaoToLotacaos < ActiveRecord::Migration
  def change
    add_column :lotacaos, :data_devolucao, :datetime
  end
end
