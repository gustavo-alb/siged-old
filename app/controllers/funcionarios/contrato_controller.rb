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
      # @funcionario.update_attributes!(params[:funcionario])
      if @funcionario.update_attributes(params[:funcionario])
      else
        jump_to(:dados_funcionais)
      end
    when :dados_adicionais
      @funcionario.update_attributes!(params[:funcionario])
    when :termino
      @funcionario.update_attributes!(params[:funcionario])
    end
    render_wizard @funcionario
  end

  def gerar_contrato
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.first
    @lotacao = @funcionario.lotacoes.ativas.first
    if @lotacao
      @contrato = @funcionario.contrato
      File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
      if ["ASSISTENTE ADMINISTRATIVO","ANALISTA ADMINISTRATIVO"].include?(@funcionario.cargo.nome)
        @modelo = "#{Rails.public_path}/modelos/contrato_nm.odt"
      else
        @modelo = "#{Rails.public_path}/modelos/contrato.odt"
      end
      contrato = ODFReport::Report.new(@modelo) do |r|
        r.add_field "CONTRATO",@contrato.numero
        r.add_field "NOME", @pessoa.nome
        r.add_field "NACIONALIDADE",@pessoa.nacionalidade
        r.add_field "ESTCIVIL",@pessoa.estado_civil
        r.add_field "RG",@pessoa.rg
        r.add_field "CPF", @pessoa.cpf
        r.add_field "ENDERECO", view_context.endereco(@pessoa)
        r.add_field "MRESID",view_context.detalhes(@pessoa.cidade)
        r.add_field "CEP",@pessoa.cep
        r.add_field "CONTATO", view_context.contato(@pessoa)
        # r.add_field "DESTINO",view_context.lotacao(@funcionario)
        r.add_field "DESTINO",@contrato.lotacao.destino.nome
        r.add_field "MOPCAO",view_context.municipio(@funcionario)
        r.add_field "MLOTACAO",view_context.municipio_destino(@lotacao.destino)
        r.add_field "CARGO", view_context.cargo_disciplina(@funcionario)
        r.add_field "FUNCAO", view_context.cargo_disciplina(@funcionario)
        r.add_field "DATA",@funcionario.data_nomeacao.to_s_br
        r.add_field "USER", (@lotacao.usuario.name.upcase if @lotacao.usuario)
        r.add_field "ANO", Date.today.year
        r.add_image :codigo_barras,  "/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png"
      end
      arquivo_contrato = contrato.generate("/tmp/contrato-#{@funcionario.matricula}.odt")
      system "unoconv -f pdf /tmp/contrato-#{@funcionario.matricula}.odt"
      f = File.open("/tmp/contrato-#{@funcionario.matricula}.pdf",'r')
      send_file(f,:filename=>"Contrato Nº #{@contrato.numero}- #{@pessoa.nome}.pdf",:content_type=>"application/pdf")
    else
      redirect_to root_path, :alert => 'Este funcionário não tem lotaçõe.'
    end
  end

  def finish_wizard_path
    pessoa_funcionario_lotacoes_path(:pessoa_id=>@pessoa)
  end

end

