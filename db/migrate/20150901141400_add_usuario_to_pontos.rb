# -*- encoding : utf-8 -*-
class AddUsuarioToPontos < ActiveRecord::Migration
  def self.up
    add_column :pontos, :usuario_id, :integer
  end

  def self.down
    remove_column :pontos, :usuario_id
  end
end
