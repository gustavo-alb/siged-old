# -*- encoding : utf-8 -*-
class Periodo < ActiveRecord::Base
  #attr_accessible :abertura, :encerramento, :fim, :inicio, :status
  scope :em_aberto,where(:status=>"inscricoes_abertas")
  state_machine :status,:initial=>:inscricoes_abertas do
    event :fechar do
      transition :inscricoes_abertas=>:inscricoes_encerradas
    end
    event :prorrogar do
      transition :inscricoes_encerradas=>:inscricoes_abertas
    end
    event :tramitar_periodo do
      transition :inscricoes_encerradas=>:tramites_internos
    end
  end
end
