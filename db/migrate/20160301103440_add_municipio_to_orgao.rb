class AddMunicipioToOrgao < ActiveRecord::Migration
  def change
    add_column :orgaos, :municipio_id, :integer
  end
end
