class AddSituacaoToFuncionario < ActiveRecord::Migration
  def change
    add_column :funcionarios, :situacao_id, :integer
  end
end
