# -*- encoding : utf-8 -*-
class Folha::Folha < ActiveRecord::Base
  belongs_to :competencia
  has_many :financeiros
  belongs_to :fonte_recurso,:class_name=>"Folha::FonteRecurso"
  validates_presence_of :ano,:mes,:competencia_id,:entidade_id
  # scope :ativas,:conditions=>["ativa = true"]
  #scope :atual, lambda { |a| where( ['ativa = ?',a]) }
  def total_financeiros
    valor_total = 0.0
    fins = self.financeiros.all
    fins.each do |f|
      valor_total+=f.valor
    end
    return valor_total
  end
end
