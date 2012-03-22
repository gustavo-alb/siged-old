class AddAttachmentArquivoToAdministracao < ActiveRecord::Migration
  def self.up
    add_column :administracao_tarefas, :arquivo_file_name, :string
    add_column :administracao_tarefas, :arquivo_content_type, :string
    add_column :administracao_tarefas, :arquivo_file_size, :integer
    add_column :administracao_tarefas, :arquivo_updated_at, :datetime
  end

  def self.down
    remove_column :administracao_tarefas, :arquivo_file_name
    remove_column :administracao_tarefas, :arquivo_content_type
    remove_column :administracao_tarefas, :arquivo_file_size
    remove_column :administracao_tarefas, :arquivo_updated_at
  end
end
