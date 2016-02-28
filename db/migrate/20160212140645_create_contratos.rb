class CreateContratos < ActiveRecord::Migration
  def change
    create_table :contratos do |t|
      t.integer :funcionario_id
      t.date :inicio
      t.date :termino
      t.integer :lotacao_id
      t.decimal :salario

      t.timestamps
    end
  end
end
