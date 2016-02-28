class AddNumeroToContrato < ActiveRecord::Migration
  def change
    add_column :contratos, :numero, :integer
  end
end
