class CreateContratos < ActiveRecord::Migration
  def change
    create_table :contratos do |t|
      t.integer :numero
      t.decimal :salario
      t.integer :funcionario_id
      t.integer :lotacao_id

      t.timestamps
    end
  end
end
