# -*- encoding : utf-8 -*-
class PessoasController < ApplicationController
  load_and_authorize_resource
  before_filter :dados_essenciais,:parametro

  def index
    @q = Pessoa.ransack(params[:q])
    if params[:q] and params[:q].size>0
      @busca = params[:q][:nome_or_cpf_or_rg_or_funcionarios_matricula_cont]
      if params[:sem_lotacao]=="true" and params[:mais_de_um_vinculo].nil?
        @pessoas = @q.result.order('nome ASC').sem_lotacao.uniq.paginate :page => params[:page], :per_page => 10
      elsif params[:mais_de_um_vinculo]=="true" and params[:sem_lotacao].nil?
        @pessoas = @q.result.order('nome ASC').mais_de_um_vinculo.uniq.paginate :page => params[:page], :per_page => 10
      elsif params[:sem_lotacao]=="true" and params[:mais_de_um_vinculo]=="true"
        @pessoas = @q.result.order('nome ASC').sem_lotacao_com_mais_de_um_vinculo.uniq.paginate :page => params[:page], :per_page => 10
      else
        @pessoas = @q.result(distinct: true).order('nome ASC').paginate :page => params[:page], :per_page => 10
      end
    else
      @pessoas = Pessoa.order("nome asc").paginate :page => params[:page], :per_page => 10
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "pessoas" }
      format.xml  { render :xml => @pessoas }
    end
  end

  def nao_lotados
    @q = Pessoa.ransack(params[:q])
    if params[:q] and params[:q].size>0
      @busca = params[:q][:nome_or_cpf_or_rg_or_funcionarios_matricula_cont]
      @pessoas = @q.result(distinct: true).order('nome ASC').sem_lotacao.paginate :page => params[:page], :per_page => 10
    else
      @pessoas = Pessoa.sem_lotacao.order("nome ASC").paginate :page => params[:page], :per_page => 10
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "pessoas" }
      format.xml  { render :xml => @pessoas }
    end
  end


  def distrito
    if params[:municipio].size>0
      @municipio = Municipio.find(params[:municipio])
      @distritos = @municipio.distritos.all.collect{|m|[m.nome,m.id]}
      if @distritos.size>0
        render :partial=>"distritos"
      else
        render :partial=>"sem_distritos"
      end
    else
      render :partial=>"sem_distritos"
    end
  end

  def dashboard
    @q = Pessoa.ransack(params[:q])
    if params[:q] and params[:q].size>0
      @busca = params[:q][:nome_or_cpf_or_rg_or_funcionarios_matricula_cont]
      if params[:sem_lotacao]=="true" and params[:mais_de_um_vinculo].nil?
        @pessoas = @q.result.order('nome ASC').sem_lotacao.uniq.paginate :page => params[:page], :per_page => 10
      elsif params[:mais_de_um_vinculo]=="true" and params[:sem_lotacao].nil?
        @pessoas = @q.result.order('nome ASC').mais_de_um_vinculo.uniq.paginate :page => params[:page], :per_page => 10
      elsif params[:sem_lotacao]=="true" and params[:mais_de_um_vinculo]=="true"
        @pessoas = @q.result.order('nome ASC').sem_lotacao_com_mais_de_um_vinculo.uniq.paginate :page => params[:page], :per_page => 10
      else
        @pessoas = @q.result(distinct: true).order('nome ASC').paginate :page => params[:page], :per_page => 10
      end
    else
      @pessoas = Pessoa.order("nome asc").paginate :page => params[:page], :per_page => 10
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "pessoas" }
      format.xml  { render :xml => @pessoas }
    end
  end

  def departamento
    @departamento = Departamento.find params[:departamento]
    @pessoa = Pessoa.find(params[:pessoa_id])
    render :partial=>"qualificar"
  end

  def especificar_lotacao
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = Funcionario.find(params[:funcionario_id])
    render :layout=>'facebox'
  end


  def qualificar_funcionario
    @departamentos = Departamento.order(:nome).collect{|p|[p.nome,p.id]}
    @pessoa = Pessoa.find(params[:pessoa_id])
    render :partial=>"qualificar_funcionario"
  end

  def edicao_rapida
    @departamentos = Departamento.order(:nome).collect{|p|[p.nome,p.id]}
    @pessoa = Pessoa.find(params[:pessoa_id])
    render :partial=>"edicao_rapida"
  end

  def boletins
    @pessoa = Pessoa.find(params[:pessoa_id])
    @boletins = BoletimPessoal.da_pessoa(@pessoa.id).all.paginate :page => params[:page], :per_page => 10
  end

  def gerar_boletim
    @pessoa = Pessoa.find(params[:pessoa_id])
    @boletim = BoletimPessoa(params[:pessoa])
  end

  def boletim_pessoal
    @pessoa = Pessoa.find(params[:pessoa_id])
    # @boletim = @pessoa.boletins.find(params[:boletim_id])
    render :layout=>nil
  end

  def salvar_boletim
    @pessoa = Pessoa.find(params[:pessoa_id])
    @boletim = @pessoa.boletins.new(params[:boletim_pessoal])
    @boletim.mes = params[:date][:mes]
    @boletim.ano = params[:date][:ano]
    respond_to do |format|
      if @boletim.save
        format.html { redirect_to(pessoa_boletins_url, :notice => 'Pessoa cadastrada com sucesso.') }
        format.xml  { render :xml => @boletim, :status => :created, :location => @boletim }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @boletim.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @pessoa = Pessoa.find(params[:id])
    @listas = @pessoa.listas

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pessoa }
    end
  end
  def naturalidade
    @estado = Estado.find_by_nome(params[:estado])
    @cidades= @estado.cidades.all.collect{|c|[c.nome,c.id]}
    render :partial=>"naturalidade"
  end

  def gerar_relatorio
    pdf = PDFController.render_pdf
    send_data pdf,
    :type         => "application/pdf",
    :disposition  => "inline",
    :filename     => "report.pdf"
  end

  def qualificacao_funcional
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionarios = @pessoa.funcionarios.ativos
    @usuario = current_user
    @departamento = Departamento.find(params[:departamento][:departamento_id])

    qualificacao = ODFReport::Report.new("#{Rails.public_path}/modelos/nova_qualificacao.odt") do |r|
      r.add_field "DESTINODEPARTAMENTO", @departamento.nome
      r.add_field "NOME", @pessoa.nome
      r.add_field "CPF", @pessoa.cpf
      r.add_field "ENDERECO", view_context.endereco(@pessoa)
      r.add_field "TELEFONE", view_context.telefones_pessoa(@pessoa,"qualificacao")
      r.add_field "USER", @usuario.name
      r.add_field "DATA", Time.now.strftime("%d de %B de %Y").downcase
      r.add_field "DATAHORA", Time.now.strftime("%d/%m/%Y às %H:%M:%S").downcase
      r.add_table("FUNCIONARIOS", @funcionarios) do |t|
        t.add_column("CARGO_E_MATRICULA") { |t| view_context.cargo_e_matricula(t) }
        t.add_column("QUADRO") { |t| view_context.qualificacao_funcional_regime(t,"qualificacao") }
        t.add_column("MUNICIPIO_OPCAO") { |t| view_context.municipio_opcao(t) }
        t.add_column("ADMISSÃO") { |t| view_context.data_nomeacao(t) }
        t.add_column("ORGAO") { |t| view_context.orgao_do_funcionario(t) }
        t.add_column("LOTACAO") { |t| view_context.lotacao_atualizada(t.lotacoes.last,"qualificacao") }
        t.add_column("JORNADA") { |t| view_context.jornada_funcional(t,"qualificacao") }
      end
    end
    arquivo_qualificacao = qualificacao.generate("/tmp/qualificacao-#{@pessoa.id}.odt")
    system "unoconv -f pdf /tmp/qualificacao-#{@pessoa.id}.odt"
    f = File.open("/tmp/qualificacao-#{@pessoa.id}.pdf",'r')
    send_file(f,:filename=>"Qualificacao Funcional - #{@pessoa.nome} em #{Time.now.strftime("%d de %B de %Y às %H:%M").downcase}.pdf",:content_type=>"application/pdf")
  end

  def criar_pessoa_contrato
    if params[:pessoa_contrato] and current_user.entidade? == true
      @nome = params[:pessoa_contrato][:nome]
      @cpf = params[:pessoa_contrato][:cpf]
      @rg = params[:pessoa_contrato][:rg]
      @nascimento = params[:pessoa_contrato][:nascimento]
      @nacionalidade = params[:pessoa_contrato][:nacionalidade]
      @sexo = params[:pessoa_contrato][:sexo]
      @estado_civil = params[:pessoa_contrato][:estado_civil]

      @pessoa = Pessoa.new(:nome=>@nome,:cpf=>@cpf,:rg=>@rg,:nascimento=>@nascimento,:nacionalidade=>@nacionalidade,:sexo=>@sexo,:estado_civil=>@estado_civil)
      if @pessoa.save!
        puts "chupa essa --> #{@nome} --> #{@cpf}"
        redirect_to pessoa_contrato_path(@pessoa,:dados_pessoais), notice: "Pessoa cadastrada com sucesso!"
      else
        redirect_to pessoas_path, alert: "Algo saiu como não deveria. Que tal tentar novamento? :~( "
      end
    elsif params[:pessoa_contrato] and current_user.entidade? == false
      redirect_to pessoas_path, alert: "Este usuário não possui Entidade definida. Favor entrar em contato com o Administrador do Sistema. :~( "
    else
      redirect_to pessoas_path, alert: "Algo saiu como não deveria. Que tal tentar novamento? :~( "
    end
  end

  def cancelar_pessoa_contrato
    @pessoa = Pessoa.find(params[:pessoa_id])
    # if !@pessoa.registro_valido?
    @pessoa.destroy
    # end
    redirect_to pessoas_path, :alert => 'Processo cancelado. As informações produzidas foram descartadas.'
  end

  # def qualificar
  #   @pessoa = Pessoa.find(params[:pessoa_id])
  #   @funcionarios = @pessoa.funcionarios.ativos
  #   @funcionario = @pessoa.funcionarios.first
  #   @departamento = Departamento.find(params[:departamento])
  #   @lotacoes = @pessoa.lotacoes
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.pdf do
  #       render :pdf =>"#{@funcionario.pessoa.nome.downcase.parameterize} - #{Time.now.to_s_br}",
  #         :layout => "pdf", # OPTIONAL
  #         :wkhtmltopdf=>"/usr/bin/wkhtmltopdf",
  #         :margin => {:top=> 0,
  #           :bottom=> 30},
  #         #:left=> 2,
  #         # :right=> 3},
  #         :footer=>{:html =>{:template => 'pessoas/footer.pdf.erb'}},
  #         :zoom => 0.873 ,
  #         :orientation => 'Portrait'

  #       end
  #     end
  #   end
  # end

  def lotacoes_por_escolaa
    @escola = Escola.find(1473,1539)
    @lotacoes = @escola.lotacoes.ativas.de_efetivos.de_professores

    f = 0
    identificacao = ODFReport::Report.new("#{Rails.public_path}/modelos/modelo_lotacao_por_escola.odt") do |r|
      r.add_field "RELATORIO", "Relação de servidores efetivos por escola"
      r.add_field "ESCOLA", @escola.nome
      r.add_field "MUNICIPIO",view_context.detalhes(@escola.municipio)
      r.add_field "INEP",view_context.detalhes(@escola.codigo)
      r.add_field "DATA", Time.now.strftime("%d de %B de %Y")
      r.add_field "EMISSOR", current_user.name
      r.add_table("PARTICIPANTES", @lotacoes.sort_by{|g| [g.funcionario.disciplina_contratacao.nome, g.funcionario.pessoa.nome ] } ) do |t|
        t.add_column("ORDEM"){|a| f && f+=1}
        t.add_column("MATRICULA") { |t| view_context.detalhes(t.funcionario.matricula) }
        t.add_column("FUNCIONARIO") { |t| view_context.detalhes(t.funcionario.pessoa) }
        t.add_column("CARGO") { |t| view_context.cargo_disciplina(t.funcionario) }
        t.add_column("CATEGORIA") { |t| view_context.categorias_gerais(t.funcionario) }
        # t.add_column("FUNCIONARIO") { |t|t.funcionario.id }
      end


    #     end
    #     arquivo_iestudantis = identificacao.generate("/tmp/identificacao-#{componente.object_id}.odt")
    #     system "unoconv -f pdf /tmp/identificacao-#{componente.object_id}.odt"
    #     identificacoes << CombinePDF.load("/tmp/identificacao-#{componente.object_id}.pdf")
  end

    # end
    # send_data identificacoes.to_pdf, filename: "Listas de frequências - #{ @evento.nome }.pdf ", type: "application/pdf"
    arquivo_iestudantil = identificacao.generate("/tmp/iestudantil_do_aluno-#{@escola.id}.odt")
    system "unoconv -f pdf /tmp/iestudantil_do_aluno-#{@escola.id}.odt"
    f = File.open("/tmp/iestudantil_do_aluno-#{@escola.id}.pdf",'r')
    send_file(f,:filename=>"Identidade Estudantil - #{@escola.id}.pdf",:content_type=>"application/pdf")
  end

  def new
    @pessoa = Pessoa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pessoa }
    end
  end

  def edit
    @pessoa = Pessoa.find(params[:id])
  end

  def create
    @pessoa = Pessoa.new(params[:pessoa])
    respond_to do |format|
      if @pessoa.save
        format.html { redirect_to(@pessoa, :notice => 'Pessoa cadastrada com sucesso.') }
        format.xml  { render :xml => @pessoa, :status => :created, :location => @pessoa }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @pessoa = Pessoa.find(params[:id])
    if params[:data] and !params[:data][:nascimento].blank?
      @data = (params[:data][:nascimento].to_date).strftime
      @pessoa.nascimento = @data
    end
    respond_to do |format|
      if @pessoa.update_attributes(params[:pessoa])
        format.html { redirect_to(@pessoa, :notice => 'pessoa was successfully updated.') }
        format.json { respond_with_bip(@pessoa) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@pessoa) }
      end
    end
  end

  def destroy
    @pessoa = Pessoa.find(params[:id])
    @pessoa.destroy
    respond_to do |format|
      format.html { redirect_to(:back,:notice=>"Apagado com sucesso") }
      format.xml  { head :ok }
    end
  end

  def adicionar_a_lista
    @pessoa = Pessoa.find(params[:pessoa_id])
    @lista = @pessoa.listas.new
    #roles = User.usuario_atual.role_ids
    if @pessoa.listas.size>0
      tipos = @pessoa.listas.collect{|l|l.tipo_lista.id}
      @tipos_lista = TipoLista.pessoal_filtro(tipos).all.collect{|t|[t.nome,t.id]}
    else
      @tipos_lista = TipoLista.pessoal.all.collect{|t|[t.nome,t.id]}
    end
    render :partial=>"adicionar_a_lista"
  end

  def salvar_lista
    @pessoa = Pessoa.find(params[:pessoa_id])
    @lista = @pessoa.listas.new(params[:lista])
    respond_to do |format|
      if @lista.save
        format.html { redirect_to(:back, :notice => "Pessoa adicionada à lista #{@lista.tipo_lista.nome} com sucesso.") }
        format.xml  { render :xml => @pessoa, :status => :created, :location => @pessoa }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @lista.errors, :status => :unprocessable_entity }
      end
    end
  end

  def contratos
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @q = Pessoa.ransack(params[:q])
    if params[:q] and params[:q].size>0
      @busca = params[:q][:nome_or_cpf_or_rg_or_funcionarios_matricula_cont]
      @pessoas = @q.result(distinct: true).joins(:funcionarios).where("funcionarios.categoria_id = ? and funcionarios.ativo = ?",@categoria,true).order('nome ASC').paginate :page => params[:page], :per_page => 10
    else
      @pessoas = Pessoa.joins(:funcionarios).where("funcionarios.categoria_id = ? and funcionarios.ativo = ?",@categoria,true).order("nome asc").paginate :page => params[:page], :per_page => 10
    end
  end

  def contratos_administrativos
    @categorias_contrato = Categoria.where("nome ilike ?","%contrato%").collect{|c|[c.nome,c.id]}
    @niveis = ReferenciaNivel.order(:codigo).collect{|n|["#{n.nome} - #{n.codigo} - #{n.jornada}H",n.id]}
  end

  def contrato_novo
    # @pessoa = Pessoa.find(params[:pessoa_id])
    @cargo = Cargo.find_by_nome('CARGO NAT ESPECIAL')
    @categoria = Categoria.find_by_nome('Contrato Administrativo')
    @nivel = ReferenciaNivel.find_by_nome('Natureza Especial')
    @municipio = Municipio.find_by_nome('Macapá')
    @entidade = Entidade.find_by_nome('Governo do Estado do Amapá')
    @orgao = Orgao.find_by_nome('Secretaria de Estado da Educação')
    @situacao = Situacao.find_by_nome("Inativo")

    # Criacao de um novo funcionario com atributos
    @funcionario = @pessoa.funcionarios.create!(:cargo=>@cargo, :categoria=>@categoria, :nivel=>@nivel, :municipio=>@municipio,:entidade=>@entidade, :orgao=>@orgao, :data_nomeacao=>DateTime.now, :situacao=>@situacao)
    @contrato = Contrato.create!(:funcionario_id=>@funcionario.id,:numero=>(if Contrato.last then Contrato.last.numero+1 else 1 end))

    respond_to do |format|
      if @funcionario.save
        format.js   { render :layout => false }
        puts "fsssssssssilho da putaaaaaaaaaaaaaa"
      else
        puts "Caraaaaaaaaaaaaaaaaaaaaaaaaaaaaalho"
        redirect_to pessoa_path(@pessoa), alert: "Você já possui uma inscrição ativa para esta atividade. :~("
      end
    end
  end

  def novo_contrato
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @pessoa = Pessoa.new
    @funcionario = @pessoa.funcionarios.new
    @lotacao = @funcionario.lotacoes.new
  end

  def salvar_contrato
    @categoria = Categoria.find_by_nome("Contrato Administrativo")
    @entidade = Entidade.find_by_nome("Governo do Estado do Amapá")
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @pessoa = Pessoa.new(params[:pessoa])
    @funcionario = @pessoa.funcionarios.new(params[:funcionario])
    @lotacao = @funcionario.lotacoes.new(params[:lotacao])
    @distritos = @funcionario.municipio.distritos.all.collect{|m|[m.nome,m.id]}
    respond_to do |format|
      if @pessoa.save
        format.html { redirect_to(@pessoa, :notice => 'Pessoa cadastrada com sucesso.') }
        format.xml  { render :xml => @pessoa, :status => :created, :location => @pessoa }
      else
        format.html { render :action => "novo_contrato" }
        format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      end

    end
  end

  def editar_contrato
    @distritos = @municipio.distritos.all.collect{|m|[m.nome,m.id]}
  end

  def atualizar_contrato
    @distritos = @municipio.distritos.all.collect{|m|[m.nome,m.id]}
  end

  def detalhes_contrato
    @pessoa = Pessoa.find(params[:pessoa_id])
  end

  def parametro
    params[:atual] = "RH"
    params[:ativo] = "RH"
  end

  def teste_lista_lotacao
    lista = []
    lista << Funcionario.find_by_matricula('300586')
    lista << Funcionario.find_by_matricula('289485')
    lista << Funcionario.find_by_matricula('419885')

    pasta = Workbook::Book.open("public/modelos/relatorio_docente.xls")
    planilha = pasta.sheet.table
    linha_modelo = planilha[1]

    lista1 = lista.sort_by{|f|f.pessoa.nome}
    lista1.each.with_index(2) do |f,i|
      planilha << linha_modelo.clone
      planilha[i][0] = f.pessoa.nome
      planilha[i][1] = f.pessoa.cpf
      planilha[i][2] = f.pessoa.rg
      planilha[i][3] = view_context.contato_simples(f.pessoa)
      planilha[i][4] = view_context.detalhes(f.disciplina_contratacao)
      planilha[i][5] = view_context.municipio(f).upcase
      planilha[i][6] = view_context.lotacao(f)
      # r.add_field "ANTERIOR",view_context.lotacao_anterior(@funcionario)
      planilha[i][7] = view_context.lotacao_anterior(f)
      # planilha[i][8] = view_context.lotacaos(f)
      # r.add_field "DESTINO",view_context.detalhes(@lotacao.destino)
      # r.add_field "NOVO_ANTERIOR",view_context.l_ant(@funcionario)
    end
    planilha.delete(linha_modelo)
    arquivo = File.open("/tmp/relatorio-#{Time.now.strftime("%d-%m-%Y-%H-%M-%S")}.xls",'w')
    pasta.write_to_xls("#{arquivo.path}")
    send_file(arquivo.path,:filename=>"Relatório Contratos Docentes.xls",:type=>"application/vnd.ms-excel")
  end


  def buscar_cod_barra
    @lotacao = Lotacao.find_by_codigo_barra(params[:buscar_cod_barra][:codigo_barra])

    respond_to do |format|
      if @lotacao
        format.html { render :partial => "lotacao_confirmar", :notice => 'Pessoa cadastrada com sucesso.' }
        format.js   { render :layout => false }
        puts "fsssssssssilho da putaaaaaaaaaaaaaa"
      else
        puts "Caraaaaaaaaaaaaaaaaaaaaaaaaaaaaalho"
        redirect_to dashboard_pessoas_path, alert: "Algo não aconteceu como deveria. Que tal tentar novamente?"
      end
    end

    # if @lotacao
    #   puts "#{@lotacao}"
    #   # render html: "<strong>#{@lotacao.id}</strong>".html_safe
    # else
    #   puts "Nada aqui"
    # end
  end

end
