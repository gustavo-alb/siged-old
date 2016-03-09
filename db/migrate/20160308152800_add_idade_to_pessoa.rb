class AddIdadeToPessoa < ActiveRecord::Migration
  def change
    add_column :pessoas, :idade, :integer
  end
end
