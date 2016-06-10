class CreateLotObservacoes < ActiveRecord::Migration
  def change
    create_table :lot_observacoes do |t|
      t.integer :lotacao_id
      t.string :item
      t.string :descricao

      t.timestamps
    end
  end
end
