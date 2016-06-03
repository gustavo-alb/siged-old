# -*- encoding : utf-8 -*-
class Pessoas::ContratoController < ApplicationController
  include Wicked::Wizard

  steps :dados_pessoais, :confirmacao

  def show
    @pessoa = Pessoa.find(params[:pessoa_id])
    case step
    when :dados_pessoais
      @municipios = Municipio.all.collect{|m|[m.nome,m.id]}
    when :dados_funcionais
      @funcionario = @pessoa.funcionarios.new
      @niveis = ReferenciaNivel.order(:codigo).collect{|n|["#{n.nome} - #{n.codigo} - #{n.jornada}H",n.id]}
    end
    render_wizard
  end

  def update
    @pessoa = Pessoa.find(params[:pessoa_id])
    case step
    when :dados_pessoais
      if @pessoa.update_attributes(params[:pessoa])
        puts "Salvo, muito salvo"
        # redirect_to contratos_administrativos_pessoa_path(:id=>@pessoa)
      else
        jump_to(:dados_pessoais)
        puts "#{@pessoa.errors.full_messages.collect{|e|e}.to_sentence}"
      end
    when :confirmacao
    end
    render_wizard @pessoa
  end

  def finish_wizard_path
    contratos_administrativos_pessoa_path(:id=>@pessoa)
  end


end

