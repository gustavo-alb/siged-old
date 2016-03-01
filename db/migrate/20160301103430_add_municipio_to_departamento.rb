class AddMunicipioToDepartamento < ActiveRecord::Migration
  def change
    add_column :departamentos, :municipio_id, :integer
  end
end
