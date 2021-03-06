# -*- encoding : utf-8 -*-
class AlterModels < ActiveRecord::Migration
  def self.up
  add_column :ambientes,:entidade_id,:integer
  add_column :arquivos,:entidade_id,:integer
  add_column :boletins_funcionais,:entidade_id,:integer
  add_column :boletins_pessoais,:entidade_id,:integer
  add_column :cargos,:entidade_id,:integer
  add_column :categoria,:entidade_id,:integer
  add_column :comissionados,:entidade_id,:integer
  add_column :departamentos,:entidade_id,:integer
  add_column :descricao_cargos,:entidade_id,:integer
  add_column :folha_eventos,:entidade_id,:integer
  add_column :folha_competencias,:entidade_id,:integer
  add_column :folha_financeiros,:entidade_id,:integer
  add_column :folha_financeiro_fixos,:entidade_id,:integer
  add_column :funcionarios,:entidade_id,:integer
  add_column :listas,:entidade_id,:integer
  add_column :lotacaos,:entidade_id,:integer
  add_column :matrizes,:entidade_id,:integer
  add_column :pessoas,:entidade_id,:integer
  add_column :processos,:entidade_id,:integer
  add_column :quadros,:entidade_id,:integer
  add_column :roles,:entidade_id,:integer
  add_column :series,:entidade_id,:integer
  add_column :settings,:entidade_id,:integer
  add_column :situacoes_juridicas,:entidade_id,:integer
  add_column :tipo_lista,:entidade_id,:integer
  add_column :turmas,:entidade_id,:integer
  add_column :vencimentos,:entidade_id,:integer
  end
  
  def self.down
  remove_column :ambientes,:entidade_id
  remove_column :arquivos,:entidade_id
  remove_column :boletins_funcionais,:entidade_id
  remove_column :boletins_pessoais,:entidade_id
  remove_column :cargos,:entidade_id
  remove_column :categoria,:entidade_id
  remove_column :comissionados,:entidade_id
  remove_column :departamentos,:entidade_id
  remove_column :descricao_cargos,:entidade_id
  remove_column :folha_eventos,:entidade_id
  remove_column :folha_competencias,:entidade_id
  remove_column :folha_financeiros,:entidade_id
  remove_column :folha_financeiro_fixos,:entidade_id
  remove_column :funcionarios,:entidade_id
  remove_column :listas,:entidade_id
  remove_column :lotacaos,:entidade_id
  remove_column :matrizes,:entidade_id
  remove_column :pessoas,:entidade_id
  remove_column :processos,:entidade_id
  remove_column :quadros,:entidade_id
  remove_column :roles,:entidade_id
  remove_column :series,:entidade_id
  remove_column :settings,:entidade_id
  remove_column :situacoes_juridicas,:entidade_id
  remove_column :tipo_lista,:entidade_id
  remove_column :turmas,:entidade_id
  remove_column :vencimentos,:entidade_id
  end
end

