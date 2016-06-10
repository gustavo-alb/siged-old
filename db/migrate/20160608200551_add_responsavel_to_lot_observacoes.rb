class AddResponsavelToLotObservacoes < ActiveRecord::Migration
  def change
    add_column :lot_observacoes, :responsavel, :string
  end
end
