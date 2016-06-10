class CreateRelatorios < ActiveRecord::Migration
  def change
    create_table :relatorios do |t|
      t.string :index
      t.string :show

      t.timestamps
    end
  end
end
