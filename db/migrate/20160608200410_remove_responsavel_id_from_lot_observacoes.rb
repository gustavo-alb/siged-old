class RemoveResponsavelIdFromLotObservacoes < ActiveRecord::Migration
  def up
    remove_column :lot_observacoes, :responsavel_id
  end

  def down
    add_column :lot_observacoes, :responsavel_id, :integer
  end
end
