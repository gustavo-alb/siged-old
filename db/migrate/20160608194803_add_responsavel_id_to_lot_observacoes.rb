class AddResponsavelIdToLotObservacoes < ActiveRecord::Migration
  def change
    add_column :lot_observacoes, :responsavel_id, :integer
  end
end
