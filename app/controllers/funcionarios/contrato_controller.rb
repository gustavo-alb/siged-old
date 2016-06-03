# -*- encoding : utf-8 -*-
class Funcionarios::ContratoController < ApplicationController
  include Wicked::Wizard

  steps :dados_pessoais, :dados_funcionais, :dados_adicionais, :termino

  def show
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = @funcionario.pessoa
    case step
    when :dados_funcionais
      @orgao = Orgao.find_by_nome("Secretaria de Estado da Educação")
      @niveis = ReferenciaNivel.order(:codigo).collect{|n|["#{n.nome} - #{n.codigo} - #{n.jornada}H",n.id]}
      @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    when :dados_adicionais
      @disciplinas = DisciplinaContratacao.order(:nome).collect{|p|[p.nome,p.id]}
      @distritos = @funcionario.municipio.distritos.all.collect{|m|[m.nome,m.id]}
    when :termino
      @situacao = Situacao.find_by_nome('Ativo')
    end
    render_wizard
  end

  def update
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = Pessoa.find(params[:pessoa_id])
    case step
    when :dados_pessoais
      if @pessoa.update_attributes(params[:pessoa])
      else
        jump_to(:dados_pessoais)
        puts "#{@pessoa.errors.full_messages.collect{|e|e}.to_sentence}"
        #inserir um flash de erro
      end
    when :dados_funcionais
      @funcionario.update_attributes!(params[:funcionario])
    when :dados_adicionais
      @funcionario.update_attributes!(params[:funcionario])
    when :termino
      @funcionario.update_attributes!(params[:funcionario])
    end
    render_wizard @funcionario
  end

  def finish_wizard_path
    pessoa_funcionario_lotacoes_path(:pessoa_id=>@pessoa)
  end

end

