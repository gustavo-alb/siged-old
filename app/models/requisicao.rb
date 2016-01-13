# -*- encoding : utf-8 -*-
class Requisicao < ActiveRecord::Base
  #attr_accessible :funcionario_id, :periodo_id, :status, :tipo_requisicao,:funcionario_attributes,:pessoa_attributes,:ambiente,:ambiente_cd
  scope :do_funcionario, lambda {|id|where("funcionario_id = ?",id) }
  scope :em_aberto, where("status in (?)",['aguardando_liberacao','aguardando_tramites_internos','aguardando_envio_a_sead','aguardando_tramites_sead','aguardando_recolhimento_de_portaria','aguardando_notificacao_do_nao_concedimento'])
  belongs_to :funcionario,:inverse_of=>:requisicoes
  has_one :pessoa,:through=>:funcionario
  belongs_to :periodo
  belongs_to :lotacao,:polymorphic=>true
  validates_presence_of :tipo_requisicao,:periodo_id,:message=>"Informação Necessária"
  accepts_nested_attributes_for :funcionario
  accepts_nested_attributes_for :pessoa
  validates_associated :funcionario
  validates_associated :pessoa
  validate :vquantidade,:on=>:create

  state_machine :status,:initial=>:aguardando_liberacao  do
    event :tramitar_internamente do
      transition :aguardando_liberacao=>:aguardando_tramites_internos
    end
    event :enviar do
      transition :aguardando_tramites_internos=>:aguardando_envio_a_sead
    end
    event :tramitar_externamente do
      transition :aguardando_envio_a_sead=>:aguardando_tramites_sead
    end
    event :retornar do
      transition :aguardando_tramites_sead =>[:aguardando_recolhimento_de_portaria,:aguardando_notificacao_do_nao_concedimento]
    end
  end


  def vquantidade
    if self.funcionario.requisicoes.em_aberto.any?
      self.errors.add(:periodo_id,"Você já tem uma requisição em andamento.")
      self.errors.add(:tipo_requisicao,"Você já tem uma requisição em andamento.")
    end
  end
end
