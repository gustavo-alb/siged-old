# -*- encoding : utf-8 -*-
class Mensagem < ActiveRecord::Base
  belongs_to :usuario,:class_name=>'User'
  belongs_to :destinatario,:class_name=>'User'
  validates_presence_of :texto,:tipo
  # validate do |mensagem|
  # 	if self.tipo!='NOTÍCIA' and self.destinatario_id.blank?
  # 		mensagem.errors.add_to_base("É necessário um destinatário.")
  # 	elsif self.tipo=='NOTÍCIA' and !self.destinatario_id.blank?
  # 		mensagem.errors.add_to_base("Notícias não podem ter um destinatário.")
  # 	end
  # end
  scope :entrada, lambda {|id|where("destinatario_id = ?",id) }
  scope :noticias,  -> { where("tipo = ?",'NOTÍCIA')}


  TIPO1=[
    ['Erro','ERRO'],
    ['Dúvida','DÚVIDA'],
    ['Crítica','CRÍTICA'],
    ['Sugestão','SUGESTÃO'],
    ['Contato','CONTATO']
  ]
  TIPO2=[['Notícia','NOTÍCIA'],['Contato','CONTATO']]
end
