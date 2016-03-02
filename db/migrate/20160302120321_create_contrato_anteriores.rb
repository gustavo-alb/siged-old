class CreateContratoAnteriores < ActiveRecord::Migration
  def change
    create_table :contrato_anteriores do |t|
      t.string :nome
      t.string :cpf
      t.string :rg
      t.string :matricula
      t.string :lotacao
      t.string :cargo
      t.string :disciplina
      t.string :municipio
      t.string :distrito

      t.timestamps
    end
  end
end
