# -*- encoding : utf-8 -*-
class ContratosController < ApplicationController
  before_filter :dados_essenciais,:atributos
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

  def pessoal
    @pessoa = Pessoa.new
  end

  def funcional
    @pessoa = Pessoa.new(params[:pessoa])
    @funcionario = Funcionario.new
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    respond_to do |format|
      if @pessoa.valid?
        format.html { render "funcional"}
        format.xml  { render :xml => @funcionario, :status => :created, :location => @funcionario }
      else
        format.html { render :action => "pessoal" }
        format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def lotacao
   @pessoa = Pessoa.new(params[:pessoa])
   @categoria = Categoria.find_by_nome("Contrato Administrativo")
   @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
   @funcionario = Funcionario.new(params[:funcionario])
   @lotacao = Lotacao.new
   @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
   respond_to do |format|
    if @funcionario.valid?
      format.html { render "lotacao"}
      format.xml  { render :xml => @lotacao, :status => :created, :location => @lotacao }
    else
      format.html { render :action => "funcional" }
      format.xml  { render :xml => @funcionario.errors, :status => :unprocessable_entity }
    end
  end
end


def revisar
  @pessoa = Pessoa.new(params[:pessoa])
  @funcionario = @pessoa.funcionarios.new(params[:funcionario])
  @lotacao = @funcionario.lotacoes.new(params[:lotacao])
end

def salvar
  @categoria = Categoria.find_by_nome("Contrato Administrativo")
  @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
  @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
  @pessoa = Pessoa.new(params[:pessoa])
  @funcionario = Funcionario.new(params[:funcionario])
  @lotacao = Lotacao.new(params[:lotacao])
  @funcionario.pessoa_id = @pessoa.id
  @lotacao.funcionario_id = @funcionario.id
    #@distritos = @funcionario.municipio.distritos.all.collect{|m|[m.nome,m.id]}
    #@contrato = Contrato.new(:funcionario_id=>@funcionario.id,:lotacao_id=>@lotacao.id,:numero=>(if Contrato.last then Contrato.last.numero+1 else 1 end))
    #@lotacao.contrato = @contrato
    respond_to do |format|
      if @pessoa.valid?
        @pessoa.save
        @funcionario.pessoa = @pessoa
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
    @contrato = Contrato.find_by_lotacao_id(@lotacao.id)||Contrato.create(:lotacao_id=>@lotacao.id,:funcionario_id=>@funcionario.id,:numero=>Contrato.count+1)
    File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
    contrato = ODFReport::Report.new("#{Rails.public_path}/modelos/contrato.odt") do |r|
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

  def atributos
   @atributos_pessoa = ["nome", "sexo", "endereco", "numero", "complemento", "bairro", "telefone_residencial", "telefone_celular", "nascimento", "naturalidade", "nacionalidade", "cpf", "rg", "pis_pasep", "cidade_id", "uf", "dep_ir", "dep_sf", "ano_de_chegada", "estado_civil", "escolaridade", "titulo_eleitor", "zona_eleitoral", "secao", "created_at", "updated_at", "cep", "email", "entidade_id", "slug", "pai", "mae"]
   @atributos_funcionario = ["matricula", "cpf", "cargo_nome", "cargo_id", "funcao", "orgao_id", "nivel_id", "jornada", "classe", "decreto_nomeacao", "data_nomeacao", "termo_posse", "comissao_id", "afastamento", "funcao_gratificada", "situacao_juridica", "banco", "agencia", "conta", "created_at", "updated_at", "cargo", "nivel", "sjuridica_id", "quadro_id", "disciplina_contratacao_id", "folha_id", "municipio_id", "distrito_id", "recad", "gaveta", "observacao", "recad_cargo_id", "lotacao_recad", "licenca", "escola_id", "verificado", "arquivo_id", "categoria_ids", "categoria_id", "cargo_em_comissao", "decreto_nomeacao_comissao", "data_decreto_nomeacao", "decreto_exoneracao_comissao", "data_decreto_exoneracao", "tipo_comissionado", "tipo_comissao", "comissao_ativa", "vencimento", "entidade_id", "slug", "fonte_recurso_id", "codigo_sirh", "conjunto", "usuario_id", "interiorizacao", "interiorizacao_valor", "interiorizacao_rubrica", "ativo"]
   @atributos_lotacao = ["funcionario_id", "escola_id", "carga_horaria_disponivel", "data_lotacao", "regencia_de_classe", "created_at", "updated_at", "finalizada", "codigo_barra", "ativo", "tipo_lotacao", "orgao_id", "esfera_id", "tipo_destino_id", "departamento_id", "unidade_id", "convalidada", "data_convalidacao", "convalidador_id", "entidade_id", "complementar", "ambiente_id", "data_confirmacao", "quick", "motivo", "usuario_id", "disciplina_atuacao_id", "destino_id", "destino_type", "state", "contrato_id"]
 end

end

