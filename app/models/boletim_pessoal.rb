# -*- encoding : utf-8 -*-
class BoletimPessoal < ActiveRecord::Base
  self.table_name = "boletins_pessoais"
  belongs_to :pessoa
  belongs_to :entidade
  scope :da_pessoa, lambda {|id|where("pessoa_id = ?",id) }
end
