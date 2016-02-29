# -*- encoding : utf-8 -*-
class ContratosController < ApplicationController
before_filter :dados_essenciais
      def index
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @q = Pessoa.ransack(params[:q])
    if params[:q] and params[:q].size>0
      @busca = params[:q][:nome_or_cpf_or_rg_or_funcionarios_matricula_cont]
      @pessoas = @q.result(distinct: true).joins(:funcionarios).where("funcionarios.categoria_id = ? and funcionarios.ativo = ?",@categoria,true).order('nome ASC').paginate :page => params[:page], :per_page => 10
    else
      @pessoas = Pessoa.joins(:funcionarios).where("funcionarios.categoria_id = ? and funcionarios.ativo = ?",@categoria,true).order("nome asc").paginate :page => params[:page], :per_page => 10
    end
  end

  def novo
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @pessoa = Pessoa.new
    @funcionario = @pessoa.funcionarios.new
    @lotacao = @funcionario.lotacoes.new
  end

  def salvar
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @pessoa = Pessoa.new(params[:pessoa])
    @funcionario = @pessoa.funcionarios.new(params[:funcionario])
    @lotacao = Lotacao.new(params[:lotacao])
    @distritos = @funcionario.municipio.distritos.all.collect{|m|[m.nome,m.id]}
    @contrato = Contrato.new(:funcionario_id=>@funcionario.id,:lotacao_id=>@lotacao.id,:numero=>(if Contrato.last then Contrato.last.numero+1 else 1 end))
    @lotacao.contrato = @contrato
    respond_to do |format|
      if @pessoa.valid? and @funcionario.valid?
        @pessoa.save
        @funcionario.save
        @lotacao.funcionario = @funcionario
        @lotacao.save
        format.html { redirect_to(contratos_detalhes_path(:pessoa_id=>@pessoa.id), :notice => 'Pessoa cadastrada com sucesso.') }
        format.xml  { render :xml => @pessoa, :status => :created, :location => @pessoa }
      else
        format.html { render :action => "novo" }
        format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      end

    end
  end

  def editar
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.first
    @lotacao = @funcionario.lotacoes.ativas.first
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @tipo = ""
    if @lotacao.destino_type=="Escola"
        @tipo = "REGULAR"
    else
        @tipo = "ESPECIAL"
    end
  end

  def atualizar
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.first
    @lotacao = @funcionario.lotacoes.ativas.first
    @distritos = @funcionario.municipio.distritos.all.collect{|m|[m.nome,m.id]} if @funcionario.municipio
    @tipo = ""
    if @lotacao.destino_type=="Escola"
        @tipo = "REGULAR"
    else
        @tipo = "ESPECIAL"
    end
    respond_to do |format|
      if @pessoa.valid? and @funcionario.valid? and @lotacao.valid? 
        @pessoa.update_attributes(params[:pessoa])
        @funcionario.update_attributes(params[:funcionario])
        @lotacao.update_attributes(params[:lotacao])
        format.html { redirect_to(contratos_detalhes_path(:pessoa_id=>@pessoa.id), :notice => 'Pessoa atualizada com sucesso.') }
        format.xml  { render :xml => @pessoa, :status => :created, :location => @pessoa }
      else
        format.html { render :action => "editar" }
        format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def detalhes
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.first
    @lotacao = @funcionario.lotacoes.ativas.first
  end

  def gerar
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.first
    @lotacao = @funcionario.lotacoes.ativas.first
    @contrato = @lotacao.contrato
    File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
    contrato = ODFReport::Report.new("#{Rails.public_path}/modelos/contrato.odt") do |r|
      r.add_field "CONTRATO",@contrato.numero
      r.add_field "NOME", @pessoa.nome
      r.add_field "NACIONALIDADE",@pessoa.nacionalidade
      r.add_field "ESTCIVIL",@pessoa.estado_civil
      r.add_field "RG",@pessoa.rg
      r.add_field "CPF", @pessoa.cpf
      r.add_field "ENDERECO", "#{@pessoa.endereco},Nº #{@pessoa.numero},#{@pessoa.bairro}"+", #{@pessoa.complemento if !@pessoa.complemento.blank?}"
      r.add_field "MRESID",view_context.detalhes(@pessoa.cidade)
      r.add_field "CEP",@pessoa.cep
      r.add_field "CONTATO", view_context.contato(@pessoa)
      r.add_field "DESTINO",view_context.lotacao(@funcionario)
      r.add_field "MOPCAO",view_context.detalhes(@funcionario.municipio)
      r.add_field "CARGO", view_context.cargo_disciplina(@funcionario)
      r.add_field "FUNCAO", view_context.cargo_disciplina(@funcionario)
      r.add_field "DATA",@lotacao.data_lotacao
      r.add_image :codigo_barras,  "/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png"
    end
    arquivo_contrato = contrato.generate("/tmp/contrato-#{@funcionario.matricula}.odt")
    system "unoconv -f pdf /tmp/contrato-#{@funcionario.matricula}.odt"
    f = File.open("/tmp/contrato-#{@funcionario.matricula}.pdf",'r')
    send_file(f,:filename=>"Contrato Nº #{@contrato.numero}- #{@pessoa.nome}",:content_type=>"application/pdf")

  end

  def apagar
    @pessoa = Pessoa.find(params[:pessoa_id])
    @pessoa.destroy
    redirect_to contratos_index_path,:notice=>"Contrato apagado com sucesso"
  end

end

