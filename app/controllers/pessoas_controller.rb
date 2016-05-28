# -*- encoding : utf-8 -*-
class PessoasController < ApplicationController
  load_and_authorize_resource
  before_filter :dados_essenciais,:parametro
  # GET /pessoas
  # GET /pessoas.xml


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

  # GET /pessoas/1
  # GET /pessoas/1.xml
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

  #  def gerar_relatorio
  #    table = Pessoa.order(:nome).report_table(:all,:limit=>100,
  #      :only       => %w[id nome cpf rg]
  #      )
  #   sorted_table = table.sort_rows_by("name", :order => :ascending)


  #    send_data sorted_table.to_pdf,
  #      :type         => "application/pdf",
  #      :disposition  => "inline",
  #      :filename     => "report.pdf"
  #  end

  def gerar_relatorio
    pdf = PDFController.render_pdf
    send_data pdf,
    :type         => "application/pdf",
    :disposition  => "inline",
    :filename     => "report.pdf"
  end

  def qualificacao_funcional
    @pessoa = Pessoa.find(params[:pessoa_id][:departamento_id])
    # @funcionario = Funcionario.find(params[:comissionado][:funcionario_id])
    @funcionarios = @pessoa.funcionarios.ativos
    @usuario = current_user
    # @departamento = Departamento.find(params[:departamento_id])

    f = 0
    identificacao = ODFReport::Report.new("#{Rails.public_path}/modelos/nova_qualificacao.odt") do |r|
      r.add_field "NOME", @pessoa.nome
      r.add_field "CPF", @pessoa.cpf
      r.add_field "ENDERECO", view_context.endereco(@pessoa)
      r.add_field "TELEFONE", view_context.telefones_pessoa(@pessoa,"qualificacao")
      r.add_field "USER", @usuario.name
      r.add_table("FUNCIONARIOS", @funcionarios) do |t|
        t.add_column("CARGO_E_MATRICULA") { |t| view_context.cargo_e_matricula(t) }
        t.add_column("QUADRO_CATEGORIA_JORNADA") { |t| view_context.categoria_funcional(t,"entidade_nome") }
        t.add_column("ADMISSÃO") { |t| view_context.data_nomeacao(t) }
        t.add_column("ORGAO") { |t| view_context.orgao_do_funcionario(t) }
        t.add_column("LOTACAO") { |t| view_context.lotacao_atualizada(t.lotacoes.last,"qualificacao") }
        t.add_column("JORNADA") { |t| view_context.jornada_funcional(t,"qualificacao") }
      end
    end
    arquivo_iestudantil = identificacao.generate("/tmp/iestudantil_do_aluno-#{@pessoa.id}.odt")
    system "unoconv -f pdf /tmp/iestudantil_do_aluno-#{@pessoa.id}.odt"
    f = File.open("/tmp/iestudantil_do_aluno-#{@pessoa.id}.pdf",'r')
    send_file(f,:filename=>"Identidade Estudantil - #{@pessoa.id}.pdf",:content_type=>"application/pdf")
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

  # GET /pessoas/new
  # GET /pessoas/new.xml
  def new
    @pessoa = Pessoa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pessoa }
    end
  end

  # GET /pessoas/1/edit
  def edit
    @pessoa = Pessoa.find(params[:id])
  end

  # POST /pessoas
  # POST /pessoas.xml
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

  # PUT /pessoas/1
  # PUT /pessoas/1.xml
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


      # if @pessoa.update_attributes(params[:pessoa])
      #   if params[:edicao_rapida]
      #     format.html { redirect_to(:back, :notice => 'Pessoa atualizada com sucesso.') }
      #     format.xml  { head :ok }
      #   else
      #     format.html { redirect_to(@pessoa, :notice => 'Pessoa atualizada com sucesso.') }
      #     format.xml  { head :ok }
      #   end
      # else
      #   format.html { render :action => "edit" }
      #   format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      # end
    end
  end

  # def update
  #   @user = User.find params[:id]

  #   respond_to do |format|
  #     if @user.update_attributes(params[:user])
  #       format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
  #       format.json { respond_with_bip(@user) }
  #     else
  #       format.html { render :action => "edit" }
  #       format.json { respond_with_bip(@user) }
  #     end
  #   end
  # end

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
    lista << Funcionario.find_by_matricula('414883')
    lista << Funcionario.find_by_matricula('434981')
    lista << Funcionario.find_by_matricula('255122')
    lista << Funcionario.find_by_matricula('494933')
    lista << Funcionario.find_by_matricula('287245')
    lista << Funcionario.find_by_matricula('338559')
    lista << Funcionario.find_by_matricula('328456')
    lista << Funcionario.find_by_matricula('430153')
    lista << Funcionario.find_by_matricula('328480')
    lista << Funcionario.find_by_matricula('314439')
    lista << Funcionario.find_by_matricula('409405')
    lista << Funcionario.find_by_matricula('432466')
    lista << Funcionario.find_by_matricula('402966')
    lista << Funcionario.find_by_matricula('315354')
    lista << Funcionario.find_by_matricula('407720')
    lista << Funcionario.find_by_matricula('620190')
    lista << Funcionario.find_by_matricula('328693')
    lista << Funcionario.find_by_matricula('431729')
    lista << Funcionario.find_by_matricula('318612')
    lista << Funcionario.find_by_matricula('254290')
    lista << Funcionario.find_by_matricula('415588')
    lista << Funcionario.find_by_matricula('319198')
    lista << Funcionario.find_by_matricula('620017')
    lista << Funcionario.find_by_matricula('429260')
    lista << Funcionario.find_by_matricula('250112')
    lista << Funcionario.find_by_matricula('614343')
    lista << Funcionario.find_by_matricula('614360')
    lista << Funcionario.find_by_matricula('433926')
    lista << Funcionario.find_by_matricula('312509')
    lista << Funcionario.find_by_matricula('316857')
    lista << Funcionario.find_by_matricula('247944')
    lista << Funcionario.find_by_matricula('290475')
    lista << Funcionario.find_by_matricula('286567')
    lista << Funcionario.find_by_matricula('422134')
    lista << Funcionario.find_by_matricula('284068')
    lista << Funcionario.find_by_matricula('440990')
    lista << Funcionario.find_by_matricula('328529')
    lista << Funcionario.find_by_matricula('498920')
    lista << Funcionario.find_by_matricula('284173')
    lista << Funcionario.find_by_matricula('431990')
    lista << Funcionario.find_by_matricula('440973')
    lista << Funcionario.find_by_matricula('416215')
    lista << Funcionario.find_by_matricula('618721')
    lista << Funcionario.find_by_matricula('618705')
    lista << Funcionario.find_by_matricula('620220')
    lista << Funcionario.find_by_matricula('889229')
    lista << Funcionario.find_by_matricula('359718')
    lista << Funcionario.find_by_matricula('326658')
    lista << Funcionario.find_by_matricula('314862')
    lista << Funcionario.find_by_matricula('427136')
    lista << Funcionario.find_by_matricula('430129')
    lista << Funcionario.find_by_matricula('321842')
    lista << Funcionario.find_by_matricula('329231')
    lista << Funcionario.find_by_matricula('408816')
    lista << Funcionario.find_by_matricula('284645')
    lista << Funcionario.find_by_matricula('428965')
    lista << Funcionario.find_by_matricula('619787')
    lista << Funcionario.find_by_matricula('284220')
    lista << Funcionario.find_by_matricula('317250')
    lista << Funcionario.find_by_matricula('612154')
    lista << Funcionario.find_by_matricula('251399')
    lista << Funcionario.find_by_matricula('289833')
    lista << Funcionario.find_by_matricula('285501')
    lista << Funcionario.find_by_matricula('416487')
    lista << Funcionario.find_by_matricula('250040')
    lista << Funcionario.find_by_matricula('833096')
    lista << Funcionario.find_by_matricula('615064')
    lista << Funcionario.find_by_matricula('317942')
    lista << Funcionario.find_by_matricula('312614')
    lista << Funcionario.find_by_matricula('428850')
    lista << Funcionario.find_by_matricula('499145')
    lista << Funcionario.find_by_matricula('328596')
    lista << Funcionario.find_by_matricula('282030')
    lista << Funcionario.find_by_matricula('319511')
    lista << Funcionario.find_by_matricula('429180')
    lista << Funcionario.find_by_matricula('317837')
    lista << Funcionario.find_by_matricula('360350')
    lista << Funcionario.find_by_matricula('317675')
    lista << Funcionario.find_by_matricula('287814')
    lista << Funcionario.find_by_matricula('619671')
    lista << Funcionario.find_by_matricula('322911')
    lista << Funcionario.find_by_matricula('410080')
    lista << Funcionario.find_by_matricula('328510')
    lista << Funcionario.find_by_matricula('618799')
    lista << Funcionario.find_by_matricula('428876')
    lista << Funcionario.find_by_matricula('290483')
    lista << Funcionario.find_by_matricula('432474')
    lista << Funcionario.find_by_matricula('254606')
    lista << Funcionario.find_by_matricula('254703')
    lista << Funcionario.find_by_matricula('334200')
    lista << Funcionario.find_by_matricula('431885')
    lista << Funcionario.find_by_matricula('429392')
    lista << Funcionario.find_by_matricula('396923')
    lista << Funcionario.find_by_matricula('430110')
    lista << Funcionario.find_by_matricula('633801')
    lista << Funcionario.find_by_matricula('621595')
    lista << Funcionario.find_by_matricula('432245')
    lista << Funcionario.find_by_matricula('328626')
    lista << Funcionario.find_by_matricula('249432')
    lista << Funcionario.find_by_matricula('286214')
    lista << Funcionario.find_by_matricula('328642')
    lista << Funcionario.find_by_matricula('330205')
    lista << Funcionario.find_by_matricula('618233')
    lista << Funcionario.find_by_matricula('290386')
    lista << Funcionario.find_by_matricula('313343')
    lista << Funcionario.find_by_matricula('621617')
    lista << Funcionario.find_by_matricula('432156')
    lista << Funcionario.find_by_matricula('408824')
    lista << Funcionario.find_by_matricula('365181')
    lista << Funcionario.find_by_matricula('409022')
    lista << Funcionario.find_by_matricula('431915')
    lista << Funcionario.find_by_matricula('312142')
    lista << Funcionario.find_by_matricula('621625')
    lista << Funcionario.find_by_matricula('289264')
    lista << Funcionario.find_by_matricula('315052')
    lista << Funcionario.find_by_matricula('408360')
    lista << Funcionario.find_by_matricula('245674')
    lista << Funcionario.find_by_matricula('399841')
    lista << Funcionario.find_by_matricula('621641')
    lista << Funcionario.find_by_matricula('614300')
    lista << Funcionario.find_by_matricula('250376')
    lista << Funcionario.find_by_matricula('323284')
    lista << Funcionario.find_by_matricula('433446')
    lista << Funcionario.find_by_matricula('402931')
    lista << Funcionario.find_by_matricula('395196')
    lista << Funcionario.find_by_matricula('627798')
    lista << Funcionario.find_by_matricula('496090')
    lista << Funcionario.find_by_matricula('282006')
    lista << Funcionario.find_by_matricula('324744')
    lista << Funcionario.find_by_matricula('621730')
    lista << Funcionario.find_by_matricula('285170')
    lista << Funcionario.find_by_matricula('286397')
    lista << Funcionario.find_by_matricula('328502')
    lista << Funcionario.find_by_matricula('246522')
    lista << Funcionario.find_by_matricula('317306')
    lista << Funcionario.find_by_matricula('633763')
    lista << Funcionario.find_by_matricula('247723')
    lista << Funcionario.find_by_matricula('429244')
    lista << Funcionario.find_by_matricula('246794')
    lista << Funcionario.find_by_matricula('621790')
    lista << Funcionario.find_by_matricula('614386')
    lista << Funcionario.find_by_matricula('289493')
    lista << Funcionario.find_by_matricula('284122')
    lista << Funcionario.find_by_matricula('409430')
    lista << Funcionario.find_by_matricula('432016')
    lista << Funcionario.find_by_matricula('248770')
    lista << Funcionario.find_by_matricula('312037')
    lista << Funcionario.find_by_matricula('621781')
    lista << Funcionario.find_by_matricula('317195')
    lista << Funcionario.find_by_matricula('613029')
    lista << Funcionario.find_by_matricula('286460')
    lista << Funcionario.find_by_matricula('365246')
    lista << Funcionario.find_by_matricula('633739')
    lista << Funcionario.find_by_matricula('434108')
    lista << Funcionario.find_by_matricula('406996')
    lista << Funcionario.find_by_matricula('498912')
    lista << Funcionario.find_by_matricula('409936')
    lista << Funcionario.find_by_matricula('314536')
    lista << Funcionario.find_by_matricula('430170')
    lista << Funcionario.find_by_matricula('289442')
    lista << Funcionario.find_by_matricula('436330')
    lista << Funcionario.find_by_matricula('360333')
    lista << Funcionario.find_by_matricula('341606')
    lista << Funcionario.find_by_matricula('248924')
    lista << Funcionario.find_by_matricula('407011')
    lista << Funcionario.find_by_matricula('493511')
    lista << Funcionario.find_by_matricula('434132')
    lista << Funcionario.find_by_matricula('314382')
    lista << Funcionario.find_by_matricula('439428')
    lista << Funcionario.find_by_matricula('289361')
    lista << Funcionario.find_by_matricula('325570')
    lista << Funcionario.find_by_matricula('619400')
    lista << Funcionario.find_by_matricula('420115')
    lista << Funcionario.find_by_matricula('313165')
    lista << Funcionario.find_by_matricula('293393')
    lista << Funcionario.find_by_matricula('615200')
    lista << Funcionario.find_by_matricula('430234')
    lista << Funcionario.find_by_matricula('633844')
    lista << Funcionario.find_by_matricula('247529')
    lista << Funcionario.find_by_matricula('430250')
    lista << Funcionario.find_by_matricula('316199')
    lista << Funcionario.find_by_matricula('314501')
    lista << Funcionario.find_by_matricula('620602')
    lista << Funcionario.find_by_matricula('289183')
    lista << Funcionario.find_by_matricula('246107')
    lista << Funcionario.find_by_matricula('286753')
    lista << Funcionario.find_by_matricula('408719')
    lista << Funcionario.find_by_matricula('619558')
    lista << Funcionario.find_by_matricula('286591')
    lista << Funcionario.find_by_matricula('618837')
    lista << Funcionario.find_by_matricula('633690')
    lista << Funcionario.find_by_matricula('254100')
    lista << Funcionario.find_by_matricula('628166')
    lista << Funcionario.find_by_matricula('433330')
    lista << Funcionario.find_by_matricula('286354')
    lista << Funcionario.find_by_matricula('286664')
    lista << Funcionario.find_by_matricula('286311')
    lista << Funcionario.find_by_matricula('318841')
    lista << Funcionario.find_by_matricula('287300')
    lista << Funcionario.find_by_matricula('417092')
    lista << Funcionario.find_by_matricula('329169')
    lista << Funcionario.find_by_matricula('252298')
    lista << Funcionario.find_by_matricula('411795')
    lista << Funcionario.find_by_matricula('406406')
    lista << Funcionario.find_by_matricula('433357')
    lista << Funcionario.find_by_matricula('633674')
    lista << Funcionario.find_by_matricula('325589')
    lista << Funcionario.find_by_matricula('612413')
    lista << Funcionario.find_by_matricula('314919')
    lista << Funcionario.find_by_matricula('360686')
    lista << Funcionario.find_by_matricula('362409')
    lista << Funcionario.find_by_matricula('284718')
    lista << Funcionario.find_by_matricula('290580')
    lista << Funcionario.find_by_matricula('428914')
    lista << Funcionario.find_by_matricula('253049')
    lista << Funcionario.find_by_matricula('319090')
    lista << Funcionario.find_by_matricula('285382')
    lista << Funcionario.find_by_matricula('316245')
    lista << Funcionario.find_by_matricula('281751')
    lista << Funcionario.find_by_matricula('360341')
    lista << Funcionario.find_by_matricula('416355')
    lista << Funcionario.find_by_matricula('314447')
    lista << Funcionario.find_by_matricula('332674')
    lista << Funcionario.find_by_matricula('281832')
    lista << Funcionario.find_by_matricula('406791')
    lista << Funcionario.find_by_matricula('315850')
    lista << Funcionario.find_by_matricula('619604')
    lista << Funcionario.find_by_matricula('415987')
    lista << Funcionario.find_by_matricula('411558')
    lista << Funcionario.find_by_matricula('627895')
    lista << Funcionario.find_by_matricula('621935')
    lista << Funcionario.find_by_matricula('621986')
    lista << Funcionario.find_by_matricula('407542')
    lista << Funcionario.find_by_matricula('621757')
    lista << Funcionario.find_by_matricula('311880')
    lista << Funcionario.find_by_matricula('409561')
    lista << Funcionario.find_by_matricula('336424')
    lista << Funcionario.find_by_matricula('282634')
    lista << Funcionario.find_by_matricula('497959')
    lista << Funcionario.find_by_matricula('407852')
    lista << Funcionario.find_by_matricula('283835')
    lista << Funcionario.find_by_matricula('317527')
    lista << Funcionario.find_by_matricula('327930')
    lista << Funcionario.find_by_matricula('429309')
    lista << Funcionario.find_by_matricula('439398')
    lista << Funcionario.find_by_matricula('327948')
    lista << Funcionario.find_by_matricula('620564')
    lista << Funcionario.find_by_matricula('429040')
    lista << Funcionario.find_by_matricula('499838')
    lista << Funcionario.find_by_matricula('364177')
    lista << Funcionario.find_by_matricula('459240')
    lista << Funcionario.find_by_matricula('312630')
    lista << Funcionario.find_by_matricula('327956')
    lista << Funcionario.find_by_matricula('496359')
    lista << Funcionario.find_by_matricula('332887')
    lista << Funcionario.find_by_matricula('251143')
    lista << Funcionario.find_by_matricula('290009')
    lista << Funcionario.find_by_matricula('633607')
    lista << Funcionario.find_by_matricula('412902')
    lista << Funcionario.find_by_matricula('407488')
    lista << Funcionario.find_by_matricula('293296')
    lista << Funcionario.find_by_matricula('330108')
    lista << Funcionario.find_by_matricula('314072')
    lista << Funcionario.find_by_matricula('414832')
    lista << Funcionario.find_by_matricula('249459')
    lista << Funcionario.find_by_matricula('612359')
    lista << Funcionario.find_by_matricula('408573')
    lista << Funcionario.find_by_matricula('316369')
    lista << Funcionario.find_by_matricula('433152')
    lista << Funcionario.find_by_matricula('423084')
    lista << Funcionario.find_by_matricula('289469')
    lista << Funcionario.find_by_matricula('622702')
    lista << Funcionario.find_by_matricula('627275')
    lista << Funcionario.find_by_matricula('341665')
    lista << Funcionario.find_by_matricula('418919')
    lista << Funcionario.find_by_matricula('327891')
    lista << Funcionario.find_by_matricula('287130')
    lista << Funcionario.find_by_matricula('246387')
    lista << Funcionario.find_by_matricula('286370')
    lista << Funcionario.find_by_matricula('428930')
    lista << Funcionario.find_by_matricula('318590')
    lista << Funcionario.find_by_matricula('313297')
    lista << Funcionario.find_by_matricula('346055')
    lista << Funcionario.find_by_matricula('622753')
    lista << Funcionario.find_by_matricula('496308')
    lista << Funcionario.find_by_matricula('434191')
    lista << Funcionario.find_by_matricula('1167200')
    lista << Funcionario.find_by_matricula('619108')
    lista << Funcionario.find_by_matricula('633500')
    lista << Funcionario.find_by_matricula('324310')
    lista << Funcionario.find_by_matricula('249360')
    lista << Funcionario.find_by_matricula('495220')
    lista << Funcionario.find_by_matricula('414034')
    lista << Funcionario.find_by_matricula('619116')
    lista << Funcionario.find_by_matricula('317683')
    lista << Funcionario.find_by_matricula('289140')
    lista << Funcionario.find_by_matricula('396966')
    lista << Funcionario.find_by_matricula('614599')
    lista << Funcionario.find_by_matricula('318299')
    lista << Funcionario.find_by_matricula('619272')
    lista << Funcionario.find_by_matricula('332720')
    lista << Funcionario.find_by_matricula('622583')
    lista << Funcionario.find_by_matricula('289132')
    lista << Funcionario.find_by_matricula('323616')
    lista << Funcionario.find_by_matricula('289213')
    lista << Funcionario.find_by_matricula('324248')
    lista << Funcionario.find_by_matricula('250180')
    lista << Funcionario.find_by_matricula('282111')
    lista << Funcionario.find_by_matricula('315818')
    lista << Funcionario.find_by_matricula('419966')
    lista << Funcionario.find_by_matricula('317829')
    lista << Funcionario.find_by_matricula('362417')
    lista << Funcionario.find_by_matricula('322075')
    lista << Funcionario.find_by_matricula('327530')
    lista << Funcionario.find_by_matricula('282740')
    lista << Funcionario.find_by_matricula('249670')
    lista << Funcionario.find_by_matricula('452653')
    lista << Funcionario.find_by_matricula('853321')
    lista << Funcionario.find_by_matricula('399485')
    lista << Funcionario.find_by_matricula('395714')
    lista << Funcionario.find_by_matricula('360279')
    lista << Funcionario.find_by_matricula('327662')
    lista << Funcionario.find_by_matricula('633577')
    lista << Funcionario.find_by_matricula('497916')
    lista << Funcionario.find_by_matricula('432083')
    lista << Funcionario.find_by_matricula('332771')
    lista << Funcionario.find_by_matricula('324329')
    lista << Funcionario.find_by_matricula('430331')
    lista << Funcionario.find_by_matricula('412449')
    lista << Funcionario.find_by_matricula('286770')
    lista << Funcionario.find_by_matricula('363057')
    lista << Funcionario.find_by_matricula('417254')
    lista << Funcionario.find_by_matricula('327581')
    lista << Funcionario.find_by_matricula('312550')
    lista << Funcionario.find_by_matricula('416452')
    lista << Funcionario.find_by_matricula('324264')
    lista << Funcionario.find_by_matricula('436410')
    lista << Funcionario.find_by_matricula('315087')
    lista << Funcionario.find_by_matricula('286737')
    lista << Funcionario.find_by_matricula('418757')
    lista << Funcionario.find_by_matricula('255416')
    lista << Funcionario.find_by_matricula('252786')
    lista << Funcionario.find_by_matricula('618560')
    lista << Funcionario.find_by_matricula('327522')
    lista << Funcionario.find_by_matricula('633534')
    lista << Funcionario.find_by_matricula('327565')
    lista << Funcionario.find_by_matricula('633526')
    lista << Funcionario.find_by_matricula('324353')
    lista << Funcionario.find_by_matricula('500356')
    lista << Funcionario.find_by_matricula('289094')
    lista << Funcionario.find_by_matricula('318310')
    lista << Funcionario.find_by_matricula('339075')
    lista << Funcionario.find_by_matricula('314137')
    lista << Funcionario.find_by_matricula('314331')
    lista << Funcionario.find_by_matricula('556122')
    lista << Funcionario.find_by_matricula('622532')
    lista << Funcionario.find_by_matricula('501158')
    lista << Funcionario.find_by_matricula('401277')
    lista << Funcionario.find_by_matricula('252271')
    lista << Funcionario.find_by_matricula('430307')
    lista << Funcionario.find_by_matricula('432334')
    lista << Funcionario.find_by_matricula('622290')
    lista << Funcionario.find_by_matricula('247839')
    lista << Funcionario.find_by_matricula('418854')
    lista << Funcionario.find_by_matricula('430323')
    lista << Funcionario.find_by_matricula('401749')
    lista << Funcionario.find_by_matricula('252832')
    lista << Funcionario.find_by_matricula('633429')
    lista << Funcionario.find_by_matricula('622320')
    lista << Funcionario.find_by_matricula('321745')
    lista << Funcionario.find_by_matricula('429570')
    lista << Funcionario.find_by_matricula('313688')
    lista << Funcionario.find_by_matricula('432997')
    lista << Funcionario.find_by_matricula('295027')
    lista << Funcionario.find_by_matricula('395137')
    lista << Funcionario.find_by_matricula('622400')
    lista << Funcionario.find_by_matricula('633402')
    lista << Funcionario.find_by_matricula('246182')
    lista << Funcionario.find_by_matricula('432229')
    lista << Funcionario.find_by_matricula('633399')
    lista << Funcionario.find_by_matricula('412066')
    lista << Funcionario.find_by_matricula('395382')
    lista << Funcionario.find_by_matricula('245550')
    lista << Funcionario.find_by_matricula('622001')
    lista << Funcionario.find_by_matricula('251380')
    lista << Funcionario.find_by_matricula('291862')
    lista << Funcionario.find_by_matricula('633313')
    lista << Funcionario.find_by_matricula('618969')
    lista << Funcionario.find_by_matricula('253251')
    lista << Funcionario.find_by_matricula('623202')
    lista << Funcionario.find_by_matricula('415669')
    lista << Funcionario.find_by_matricula('362441')
    lista << Funcionario.find_by_matricula('434230')
    lista << Funcionario.find_by_matricula('313360')
    lista << Funcionario.find_by_matricula('429104')
    lista << Funcionario.find_by_matricula('286362')
    lista << Funcionario.find_by_matricula('360058')
    lista << Funcionario.find_by_matricula('623156')
    lista << Funcionario.find_by_matricula('324337')
    lista << Funcionario.find_by_matricula('421227')
    lista << Funcionario.find_by_matricula('314994')
    lista << Funcionario.find_by_matricula('285358')
    lista << Funcionario.find_by_matricula('433144')
    lista << Funcionario.find_by_matricula('412546')
    lista << Funcionario.find_by_matricula('459224')
    lista << Funcionario.find_by_matricula('422070')
    lista << Funcionario.find_by_matricula('613070')
    lista << Funcionario.find_by_matricula('623008')
    lista << Funcionario.find_by_matricula('245402')
    lista << Funcionario.find_by_matricula('318140')
    lista << Funcionario.find_by_matricula('402958')
    lista << Funcionario.find_by_matricula('498769')
    lista << Funcionario.find_by_matricula('430340')
    lista << Funcionario.find_by_matricula('414328')
    lista << Funcionario.find_by_matricula('246174')
    lista << Funcionario.find_by_matricula('314773')
    lista << Funcionario.find_by_matricula('249440')
    lista << Funcionario.find_by_matricula('285897')
    lista << Funcionario.find_by_matricula('434337')
    lista << Funcionario.find_by_matricula('619590')
    lista << Funcionario.find_by_matricula('622893')
    lista << Funcionario.find_by_matricula('428868')
    lista << Funcionario.find_by_matricula('886203')
    lista << Funcionario.find_by_matricula('317500')
    lista << Funcionario.find_by_matricula('414450')
    lista << Funcionario.find_by_matricula('318604')
    lista << Funcionario.find_by_matricula('418870')
    lista << Funcionario.find_by_matricula('622621')
    lista << Funcionario.find_by_matricula('409197')
    lista << Funcionario.find_by_matricula('622591')
    lista << Funcionario.find_by_matricula('430420')
    lista << Funcionario.find_by_matricula('253430')
    lista << Funcionario.find_by_matricula('430404')
    lista << Funcionario.find_by_matricula('615234')
    lista << Funcionario.find_by_matricula('622508')
    lista << Funcionario.find_by_matricula('979171')
    lista << Funcionario.find_by_matricula('622540')
    lista << Funcionario.find_by_matricula('251631')
    lista << Funcionario.find_by_matricula('290092')
    lista << Funcionario.find_by_matricula('317977')
    lista << Funcionario.find_by_matricula('622524')
    lista << Funcionario.find_by_matricula('409189')
    lista << Funcionario.find_by_matricula('419923')
    lista << Funcionario.find_by_matricula('633860')
    lista << Funcionario.find_by_matricula('615188')
    lista << Funcionario.find_by_matricula('618659')
    lista << Funcionario.find_by_matricula('633852')
    lista << Funcionario.find_by_matricula('323608')
    lista << Funcionario.find_by_matricula('329410')
    lista << Funcionario.find_by_matricula('337730')
    lista << Funcionario.find_by_matricula('430382')
    lista << Funcionario.find_by_matricula('286605')
    lista << Funcionario.find_by_matricula('496456')
    lista << Funcionario.find_by_matricula('621803')
    lista << Funcionario.find_by_matricula('406384')
    lista << Funcionario.find_by_matricula('325856')
    lista << Funcionario.find_by_matricula('411809')
    lista << Funcionario.find_by_matricula('414778')
    lista << Funcionario.find_by_matricula('407135')
    lista << Funcionario.find_by_matricula('313963')
    lista << Funcionario.find_by_matricula('430455')
    lista << Funcionario.find_by_matricula('614823')
    lista << Funcionario.find_by_matricula('252220')
    lista << Funcionario.find_by_matricula('286656')
    lista << Funcionario.find_by_matricula('407500')
    lista << Funcionario.find_by_matricula('246581')
    lista << Funcionario.find_by_matricula('411647')
    lista << Funcionario.find_by_matricula('362980')
    lista << Funcionario.find_by_matricula('286982')
    lista << Funcionario.find_by_matricula('890669')
    lista << Funcionario.find_by_matricula('248274')
    lista << Funcionario.find_by_matricula('328715')
    lista << Funcionario.find_by_matricula('324523')
    lista << Funcionario.find_by_matricula('320650')
    lista << Funcionario.find_by_matricula('395390')
    lista << Funcionario.find_by_matricula('315362')
    lista << Funcionario.find_by_matricula('402443')
    lista << Funcionario.find_by_matricula('412791')
    lista << Funcionario.find_by_matricula('290467')
    lista << Funcionario.find_by_matricula('249475')
    lista << Funcionario.find_by_matricula('433403')
    lista << Funcionario.find_by_matricula('247324')
    lista << Funcionario.find_by_matricula('421294')
    lista << Funcionario.find_by_matricula('633968')
    lista << Funcionario.find_by_matricula('321621')
    lista << Funcionario.find_by_matricula('402745')
    lista << Funcionario.find_by_matricula('436488')
    lista << Funcionario.find_by_matricula('412201')
    lista << Funcionario.find_by_matricula('365130')
    lista << Funcionario.find_by_matricula('316032')
    lista << Funcionario.find_by_matricula('314420')
    lista << Funcionario.find_by_matricula('495069')
    lista << Funcionario.find_by_matricula('250589')
    lista << Funcionario.find_by_matricula('415642')
    lista << Funcionario.find_by_matricula('286702')
    lista << Funcionario.find_by_matricula('255092')
    lista << Funcionario.find_by_matricula('436496')
    lista << Funcionario.find_by_matricula('286141')
    lista << Funcionario.find_by_matricula('318078')
    lista << Funcionario.find_by_matricula('247782')
    lista << Funcionario.find_by_matricula('252247')
    lista << Funcionario.find_by_matricula('293245')
    lista << Funcionario.find_by_matricula('313483')
    lista << Funcionario.find_by_matricula('362220')
    lista << Funcionario.find_by_matricula('619337')
    lista << Funcionario.find_by_matricula('323136')
    lista << Funcionario.find_by_matricula('314978')
    lista << Funcionario.find_by_matricula('293512')
    lista << Funcionario.find_by_matricula('622117')
    lista << Funcionario.find_by_matricula('323667')
    lista << Funcionario.find_by_matricula('283460')
    lista << Funcionario.find_by_matricula('622087')
    lista << Funcionario.find_by_matricula('500500')
    lista << Funcionario.find_by_matricula('249653')
    lista << Funcionario.find_by_matricula('411906')
    lista << Funcionario.find_by_matricula('406899')
    lista << Funcionario.find_by_matricula('311960')
    lista << Funcionario.find_by_matricula('328782')
    lista << Funcionario.find_by_matricula('362387')
    lista << Funcionario.find_by_matricula('248908')
    lista << Funcionario.find_by_matricula('432938')
    lista << Funcionario.find_by_matricula('430544')
    lista << Funcionario.find_by_matricula('246379')
    lista << Funcionario.find_by_matricula('315028')
    lista << Funcionario.find_by_matricula('318779')
    lista << Funcionario.find_by_matricula('251674')
    lista << Funcionario.find_by_matricula('313645')
    lista << Funcionario.find_by_matricula('407550')
    lista << Funcionario.find_by_matricula('284270')
    lista << Funcionario.find_by_matricula('420417')
    lista << Funcionario.find_by_matricula('621390')
    lista << Funcionario.find_by_matricula('407283')
    lista << Funcionario.find_by_matricula('407526')
    lista << Funcionario.find_by_matricula('245801')
    lista << Funcionario.find_by_matricula('414360')
    lista << Funcionario.find_by_matricula('615277')
    lista << Funcionario.find_by_matricula('318493')
    lista << Funcionario.find_by_matricula('325449')
    lista << Funcionario.find_by_matricula('286281')
    lista << Funcionario.find_by_matricula('295035')
    lista << Funcionario.find_by_matricula('245879')
    lista << Funcionario.find_by_matricula('409006')
    lista << Funcionario.find_by_matricula('315141')
    lista << Funcionario.find_by_matricula('312703')
    lista << Funcionario.find_by_matricula('253952')
    lista << Funcionario.find_by_matricula('251046')
    lista << Funcionario.find_by_matricula('318736')
    lista << Funcionario.find_by_matricula('285137')
    lista << Funcionario.find_by_matricula('289191')
    lista << Funcionario.find_by_matricula('622281')
    lista << Funcionario.find_by_matricula('318027')
    lista << Funcionario.find_by_matricula('613274')
    lista << Funcionario.find_by_matricula('613681')
    lista << Funcionario.find_by_matricula('320684')
    lista << Funcionario.find_by_matricula('316601')
    lista << Funcionario.find_by_matricula('284238')
    lista << Funcionario.find_by_matricula('621439')
    lista << Funcionario.find_by_matricula('621447')
    lista << Funcionario.find_by_matricula('317748')
    lista << Funcionario.find_by_matricula('621684')
    lista << Funcionario.find_by_matricula('286419')
    lista << Funcionario.find_by_matricula('287490')
    lista << Funcionario.find_by_matricula('621528')
    lista << Funcionario.find_by_matricula('295043')
    lista << Funcionario.find_by_matricula('430625')
    lista << Funcionario.find_by_matricula('413356')
    lista << Funcionario.find_by_matricula('429147')
    lista << Funcionario.find_by_matricula('397954')
    lista << Funcionario.find_by_matricula('434892')
    lista << Funcionario.find_by_matricula('282120')
    lista << Funcionario.find_by_matricula('414271')
    lista << Funcionario.find_by_matricula('416720')
    lista << Funcionario.find_by_matricula('618616')
    lista << Funcionario.find_by_matricula('286958')
    lista << Funcionario.find_by_matricula('493643')
    lista << Funcionario.find_by_matricula('627437')
    lista << Funcionario.find_by_matricula('314498')
    lista << Funcionario.find_by_matricula('411540')
    lista << Funcionario.find_by_matricula('328170')
    lista << Funcionario.find_by_matricula('333697')
    lista << Funcionario.find_by_matricula('415820')
    lista << Funcionario.find_by_matricula('252956')
    lista << Funcionario.find_by_matricula('399434')
    lista << Funcionario.find_by_matricula('328090')
    lista << Funcionario.find_by_matricula('397270')
    lista << Funcionario.find_by_matricula('284580')
    lista << Funcionario.find_by_matricula('290327')
    lista << Funcionario.find_by_matricula('422215')
    lista << Funcionario.find_by_matricula('622036')
    lista << Funcionario.find_by_matricula('434256')
    lista << Funcionario.find_by_matricula('414220')
    lista << Funcionario.find_by_matricula('312517')
    lista << Funcionario.find_by_matricula('634026')
    lista << Funcionario.find_by_matricula('248851')
    lista << Funcionario.find_by_matricula('282936')
    lista << Funcionario.find_by_matricula('402192')
    lista << Funcionario.find_by_matricula('430609')
    lista << Funcionario.find_by_matricula('314609')
    lista << Funcionario.find_by_matricula('411973')
    lista << Funcionario.find_by_matricula('621455')
    lista << Funcionario.find_by_matricula('634069')
    lista << Funcionario.find_by_matricula('293270')
    lista << Funcionario.find_by_matricula('360554')
    lista << Funcionario.find_by_matricula('315966')
    lista << Funcionario.find_by_matricula('622150')
    lista << Funcionario.find_by_matricula('317381')
    lista << Funcionario.find_by_matricula('493449')
    lista << Funcionario.find_by_matricula('614459')
    lista << Funcionario.find_by_matricula('634093')
    lista << Funcionario.find_by_matricula('318060')
    lista << Funcionario.find_by_matricula('365262')
    lista << Funcionario.find_by_matricula('432202')
    lista << Funcionario.find_by_matricula('407194')
    lista << Funcionario.find_by_matricula('323519')
    lista << Funcionario.find_by_matricula('495336')
    lista << Funcionario.find_by_matricula('501069')
    lista << Funcionario.find_by_matricula('401692')
    lista << Funcionario.find_by_matricula('317659')
    lista << Funcionario.find_by_matricula('318450')
    lista << Funcionario.find_by_matricula('968234')
    lista << Funcionario.find_by_matricula('428841')
    lista << Funcionario.find_by_matricula('407925')
    lista << Funcionario.find_by_matricula('248215')
    lista << Funcionario.find_by_matricula('614718')
    lista << Funcionario.find_by_matricula('339113')
    lista << Funcionario.find_by_matricula('494380')
    lista << Funcionario.find_by_matricula('328138')
    lista << Funcionario.find_by_matricula('286400')
    lista << Funcionario.find_by_matricula('622184')
    lista << Funcionario.find_by_matricula('249645')
    lista << Funcionario.find_by_matricula('290432')
    lista << Funcionario.find_by_matricula('401366')
    lista << Funcionario.find_by_matricula('619930')
    lista << Funcionario.find_by_matricula('407364')
    lista << Funcionario.find_by_matricula('619817')
    lista << Funcionario.find_by_matricula('360325')
    lista << Funcionario.find_by_matricula('436550')
    lista << Funcionario.find_by_matricula('402532')
    lista << Funcionario.find_by_matricula('634131')
    lista << Funcionario.find_by_matricula('409308')
    lista << Funcionario.find_by_matricula('328120')
    lista << Funcionario.find_by_matricula('245798')
    lista << Funcionario.find_by_matricula('248312')
    lista << Funcionario.find_by_matricula('430501')
    lista << Funcionario.find_by_matricula('293474')
    lista << Funcionario.find_by_matricula('401625')
    lista << Funcionario.find_by_matricula('328146')
    lista << Funcionario.find_by_matricula('400394')
    lista << Funcionario.find_by_matricula('314064')
    lista << Funcionario.find_by_matricula('247650')
    lista << Funcionario.find_by_matricula('414409')
    lista << Funcionario.find_by_matricula('323888')
    lista << Funcionario.find_by_matricula('246000')
    lista << Funcionario.find_by_matricula('430633')
    lista << Funcionario.find_by_matricula('411574')
    lista << Funcionario.find_by_matricula('407577')
    lista << Funcionario.find_by_matricula('248096')
    lista << Funcionario.find_by_matricula('434280')
    lista << Funcionario.find_by_matricula('497010')
    lista << Funcionario.find_by_matricula('253219')
    lista << Funcionario.find_by_matricula('286621')
    lista << Funcionario.find_by_matricula('614220')
    lista << Funcionario.find_by_matricula('627682')
    lista << Funcionario.find_by_matricula('289450')
    lista << Funcionario.find_by_matricula('412180')
    lista << Funcionario.find_by_matricula('337536')
    lista << Funcionario.find_by_matricula('373567')
    lista << Funcionario.find_by_matricula('359882')
    lista << Funcionario.find_by_matricula('412686')
    lista << Funcionario.find_by_matricula('432091')
    lista << Funcionario.find_by_matricula('494399')
    lista << Funcionario.find_by_matricula('634930')
    lista << Funcionario.find_by_matricula('332640')
    lista << Funcionario.find_by_matricula('245976')
    lista << Funcionario.find_by_matricula('994740')
    lista << Funcionario.find_by_matricula('286575')
    lista << Funcionario.find_by_matricula('613355')
    lista << Funcionario.find_by_matricula('429660')
    lista << Funcionario.find_by_matricula('284319')
    lista << Funcionario.find_by_matricula('288799')
    lista << Funcionario.find_by_matricula('430870')
    lista << Funcionario.find_by_matricula('284289')
    lista << Funcionario.find_by_matricula('433136')
    lista << Funcionario.find_by_matricula('620424')
    lista << Funcionario.find_by_matricula('245623')
    lista << Funcionario.find_by_matricula('286265')
    lista << Funcionario.find_by_matricula('622370')
    lista << Funcionario.find_by_matricula('429333')
    lista << Funcionario.find_by_matricula('620360')
    lista << Funcionario.find_by_matricula('287067')
    lista << Funcionario.find_by_matricula('313556')
    lista << Funcionario.find_by_matricula('327468')
    lista << Funcionario.find_by_matricula('291099')
    lista << Funcionario.find_by_matricula('329258')
    lista << Funcionario.find_by_matricula('614505')
    lista << Funcionario.find_by_matricula('313858')
    lista << Funcionario.find_by_matricula('291110')
    lista << Funcionario.find_by_matricula('434906')
    lista << Funcionario.find_by_matricula('439312')
    lista << Funcionario.find_by_matricula('615005')
    lista << Funcionario.find_by_matricula('254770')
    lista << Funcionario.find_by_matricula('314358')
    lista << Funcionario.find_by_matricula('621870')
    lista << Funcionario.find_by_matricula('249823')
    lista << Funcionario.find_by_matricula('252263')
    lista << Funcionario.find_by_matricula('251020')
    lista << Funcionario.find_by_matricula('321907')
    lista << Funcionario.find_by_matricula('286745')
    lista << Funcionario.find_by_matricula('429171')
    lista << Funcionario.find_by_matricula('285099')
    lista << Funcionario.find_by_matricula('417157')
    lista << Funcionario.find_by_matricula('437158')
    lista << Funcionario.find_by_matricula('317888')
    lista << Funcionario.find_by_matricula('314650')
    lista << Funcionario.find_by_matricula('635731')
    lista << Funcionario.find_by_matricula('318159')
    lista << Funcionario.find_by_matricula('364290')
    lista << Funcionario.find_by_matricula('407453')
    lista << Funcionario.find_by_matricula('407534')
    lista << Funcionario.find_by_matricula('290777')
    lista << Funcionario.find_by_matricula('326615')
    lista << Funcionario.find_by_matricula('408972')
    lista << Funcionario.find_by_matricula('248673')
    lista << Funcionario.find_by_matricula('316253')
    lista << Funcionario.find_by_matricula('402338')
    lista << Funcionario.find_by_matricula('314668')
    lista << Funcionario.find_by_matricula('634832')
    lista << Funcionario.find_by_matricula('432415')
    lista << Funcionario.find_by_matricula('315753')
    lista << Funcionario.find_by_matricula('402320')
    lista << Funcionario.find_by_matricula('320153')
    lista << Funcionario.find_by_matricula('254193')
    lista << Funcionario.find_by_matricula('493813')
    lista << Funcionario.find_by_matricula('397814')
    lista << Funcionario.find_by_matricula('338150')
    lista << Funcionario.find_by_matricula('318523')
    lista << Funcionario.find_by_matricula('495735')
    lista << Funcionario.find_by_matricula('329177')
    lista << Funcionario.find_by_matricula('317950')
    lista << Funcionario.find_by_matricula('284262')
    lista << Funcionario.find_by_matricula('327441')
    lista << Funcionario.find_by_matricula('315265')
    lista << Funcionario.find_by_matricula('431761')
    lista << Funcionario.find_by_matricula('247790')
    lista << Funcionario.find_by_matricula('429678')
    lista << Funcionario.find_by_matricula('422266')
    lista << Funcionario.find_by_matricula('315869')
    lista << Funcionario.find_by_matricula('362310')
    lista << Funcionario.find_by_matricula('287466')
    lista << Funcionario.find_by_matricula('326909')
    lista << Funcionario.find_by_matricula('429686')
    lista << Funcionario.find_by_matricula('282782')
    lista << Funcionario.find_by_matricula('431010')
    lista << Funcionario.find_by_matricula('323101')
    lista << Funcionario.find_by_matricula('253871')
    lista << Funcionario.find_by_matricula('868906')
    lista << Funcionario.find_by_matricula('287091')
    lista << Funcionario.find_by_matricula('312533')
    lista << Funcionario.find_by_matricula('359777')
    lista << Funcionario.find_by_matricula('322300')
    lista << Funcionario.find_by_matricula('370460')
    lista << Funcionario.find_by_matricula('617091')
    lista << Funcionario.find_by_matricula('283436')
    lista << Funcionario.find_by_matricula('247928')
    lista << Funcionario.find_by_matricula('433888')
    lista << Funcionario.find_by_matricula('613215')
    lista << Funcionario.find_by_matricula('622028')
    lista << Funcionario.find_by_matricula('360163')
    lista << Funcionario.find_by_matricula('613371')
    lista << Funcionario.find_by_matricula('283371')
    lista << Funcionario.find_by_matricula('431060')
    lista << Funcionario.find_by_matricula('408174')
    lista << Funcionario.find_by_matricula('431710')
    lista << Funcionario.find_by_matricula('488534')
    lista << Funcionario.find_by_matricula('246760')
    lista << Funcionario.find_by_matricula('617040')
    lista << Funcionario.find_by_matricula('620386')
    lista << Funcionario.find_by_matricula('249130')
    lista << Funcionario.find_by_matricula('282065')
    lista << Funcionario.find_by_matricula('613061')
    lista << Funcionario.find_by_matricula('253146')
    lista << Funcionario.find_by_matricula('433969')
    lista << Funcionario.find_by_matricula('359696')
    lista << Funcionario.find_by_matricula('431028')
    lista << Funcionario.find_by_matricula('359971')
    lista << Funcionario.find_by_matricula('294144')
    lista << Funcionario.find_by_matricula('421529')
    lista << Funcionario.find_by_matricula('293350')
    lista << Funcionario.find_by_matricula('432725')
    lista << Funcionario.find_by_matricula('363065')
    lista << Funcionario.find_by_matricula('286672')
    lista << Funcionario.find_by_matricula('290637')
    lista << Funcionario.find_by_matricula('327140')
    lista << Funcionario.find_by_matricula('317721')
    lista << Funcionario.find_by_matricula('249777')
    lista << Funcionario.find_by_matricula('433950')
    lista << Funcionario.find_by_matricula('325201')
    lista << Funcionario.find_by_matricula('620807')
    lista << Funcionario.find_by_matricula('434299')
    lista << Funcionario.find_by_matricula('409499')
    lista << Funcionario.find_by_matricula('430943')
    lista << Funcionario.find_by_matricula('249297')
    lista << Funcionario.find_by_matricula('431095')
    lista << Funcionario.find_by_matricula('621234')
    lista << Funcionario.find_by_matricula('498580')
    lista << Funcionario.find_by_matricula('432687')
    lista << Funcionario.find_by_matricula('604135')
    lista << Funcionario.find_by_matricula('429767')
    lista << Funcionario.find_by_matricula('313424')
    lista << Funcionario.find_by_matricula('432768')
    lista << Funcionario.find_by_matricula('253928')
    lista << Funcionario.find_by_matricula('290173')
    lista << Funcionario.find_by_matricula('412082')
    lista << Funcionario.find_by_matricula('432440')
    lista << Funcionario.find_by_matricula('290130')
    lista << Funcionario.find_by_matricula('434248')
    lista << Funcionario.find_by_matricula('327239')
    lista << Funcionario.find_by_matricula('431133')
    lista << Funcionario.find_by_matricula('285374')
    lista << Funcionario.find_by_matricula('327247')
    lista << Funcionario.find_by_matricula('432490')
    lista << Funcionario.find_by_matricula('494240')
    lista << Funcionario.find_by_matricula('290505')
    lista << Funcionario.find_by_matricula('613037')
    lista << Funcionario.find_by_matricula('620246')
    lista << Funcionario.find_by_matricula('283010')
    lista << Funcionario.find_by_matricula('313769')
    lista << Funcionario.find_by_matricula('291137')
    lista << Funcionario.find_by_matricula('252824')
    lista << Funcionario.find_by_matricula('499854')
    lista << Funcionario.find_by_matricula('247910')
    lista << Funcionario.find_by_matricula('289590')
    lista << Funcionario.find_by_matricula('330140')
    lista << Funcionario.find_by_matricula('327034')
    lista << Funcionario.find_by_matricula('288926')
    lista << Funcionario.find_by_matricula('282391')
    lista << Funcionario.find_by_matricula('246778')
    lista << Funcionario.find_by_matricula('434264')
    lista << Funcionario.find_by_matricula('365165')
    lista << Funcionario.find_by_matricula('431079')
    lista << Funcionario.find_by_matricula('613304')
    lista << Funcionario.find_by_matricula('320889')
    lista << Funcionario.find_by_matricula('252743')
    lista << Funcionario.find_by_matricula('436682')
    lista << Funcionario.find_by_matricula('620300')
    lista << Funcionario.find_by_matricula('251283')
    lista << Funcionario.find_by_matricula('497967')
    lista << Funcionario.find_by_matricula('407402')
    lista << Funcionario.find_by_matricula('282855')
    lista << Funcionario.find_by_matricula('291374')
    lista << Funcionario.find_by_matricula('289817')
    lista << Funcionario.find_by_matricula('431087')
    lista << Funcionario.find_by_matricula('359904')
    lista << Funcionario.find_by_matricula('314552')
    lista << Funcionario.find_by_matricula('434140')
    lista << Funcionario.find_by_matricula('339059')
    lista << Funcionario.find_by_matricula('293229')
    lista << Funcionario.find_by_matricula('613320')
    lista << Funcionario.find_by_matricula('314390')
    lista << Funcionario.find_by_matricula('616206')
    lista << Funcionario.find_by_matricula('253065')
    lista << Funcionario.find_by_matricula('343684')
    lista << Funcionario.find_by_matricula('627410')
    lista << Funcionario.find_by_matricula('368369')
    lista << Funcionario.find_by_matricula('313572')
    lista << Funcionario.find_by_matricula('293792')
    lista << Funcionario.find_by_matricula('359785')
    lista << Funcionario.find_by_matricula('327174')
    lista << Funcionario.find_by_matricula('246808')
    lista << Funcionario.find_by_matricula('406520')
    lista << Funcionario.find_by_matricula('314404')
    lista << Funcionario.find_by_matricula('315230')
    lista << Funcionario.find_by_matricula('418765')
    lista << Funcionario.find_by_matricula('500372')
    lista << Funcionario.find_by_matricula('327026')
    lista << Funcionario.find_by_matricula('423831')
    lista << Funcionario.find_by_matricula('287415')
    lista << Funcionario.find_by_matricula('499137')
    lista << Funcionario.find_by_matricula('499129')
    lista << Funcionario.find_by_matricula('286184')
    lista << Funcionario.find_by_matricula('254720')
    lista << Funcionario.find_by_matricula('315001')
    lista << Funcionario.find_by_matricula('432598')
    lista << Funcionario.find_by_matricula('248843')
    lista << Funcionario.find_by_matricula('293261')
    lista << Funcionario.find_by_matricula('428744')
    lista << Funcionario.find_by_matricula('500836')
    lista << Funcionario.find_by_matricula('315729')
    lista << Funcionario.find_by_matricula('327042')
    lista << Funcionario.find_by_matricula('432180')
    lista << Funcionario.find_by_matricula('281581')
    lista << Funcionario.find_by_matricula('286613')
    lista << Funcionario.find_by_matricula('359939')
    lista << Funcionario.find_by_matricula('250430')
    lista << Funcionario.find_by_matricula('252255')
    lista << Funcionario.find_by_matricula('429872')
    lista << Funcionario.find_by_matricula('401820')
    lista << Funcionario.find_by_matricula('289426')
    lista << Funcionario.find_by_matricula('617431')
    lista << Funcionario.find_by_matricula('453765')
    lista << Funcionario.find_by_matricula('452548')
    lista << Funcionario.find_by_matricula('617326')
    lista << Funcionario.find_by_matricula('448281')
    lista << Funcionario.find_by_matricula('407755')
    lista << Funcionario.find_by_matricula('283487')
    lista << Funcionario.find_by_matricula('635227')
    lista << Funcionario.find_by_matricula('326992')
    lista << Funcionario.find_by_matricula('429546')
    lista << Funcionario.find_by_matricula('359890')
    lista << Funcionario.find_by_matricula('317543')
    lista << Funcionario.find_by_matricula('432695')
    lista << Funcionario.find_by_matricula('288900')
    lista << Funcionario.find_by_matricula('415480')
    lista << Funcionario.find_by_matricula('318086')
    lista << Funcionario.find_by_matricula('359980')
    lista << Funcionario.find_by_matricula('364266')
    lista << Funcionario.find_by_matricula('411639')
    lista << Funcionario.find_by_matricula('290459')
    lista << Funcionario.find_by_matricula('291269')
    lista << Funcionario.find_by_matricula('432792')
    lista << Funcionario.find_by_matricula('635219')
    lista << Funcionario.find_by_matricula('620947')
    lista << Funcionario.find_by_matricula('431109')
    lista << Funcionario.find_by_matricula('429155')
    lista << Funcionario.find_by_matricula('321672')
    lista << Funcionario.find_by_matricula('318396')
    lista << Funcionario.find_by_matricula('362360')
    lista << Funcionario.find_by_matricula('863408')
    lista << Funcionario.find_by_matricula('493902')
    lista << Funcionario.find_by_matricula('429287')
    lista << Funcionario.find_by_matricula('325139')
    lista << Funcionario.find_by_matricula('293920')
    lista << Funcionario.find_by_matricula('431044')
    lista << Funcionario.find_by_matricula('617512')
    lista << Funcionario.find_by_matricula('327727')
    lista << Funcionario.find_by_matricula('327093')
    lista << Funcionario.find_by_matricula('322261')
    lista << Funcionario.find_by_matricula('293334')
    lista << Funcionario.find_by_matricula('317560')
    lista << Funcionario.find_by_matricula('285641')
    lista << Funcionario.find_by_matricula('429716')
    lista << Funcionario.find_by_matricula('249521')
    lista << Funcionario.find_by_matricula('612332')
    lista << Funcionario.find_by_matricula('314099')
    lista << Funcionario.find_by_matricula('249076')
    lista << Funcionario.find_by_matricula('254800')
    lista << Funcionario.find_by_matricula('411590')
    lista << Funcionario.find_by_matricula('249386')
    lista << Funcionario.find_by_matricula('433217')
    lista << Funcionario.find_by_matricula('315419')
    lista << Funcionario.find_by_matricula('447714')
    lista << Funcionario.find_by_matricula('412562')
    lista << Funcionario.find_by_matricula('285960')
    lista << Funcionario.find_by_matricula('254061')
    lista << Funcionario.find_by_matricula('252794')
    lista << Funcionario.find_by_matricula('253782')
    lista << Funcionario.find_by_matricula('612383')
    lista << Funcionario.find_by_matricula('291013')
    lista << Funcionario.find_by_matricula('612367')
    lista << Funcionario.find_by_matricula('292338')
    lista << Funcionario.find_by_matricula('293830')
    lista << Funcionario.find_by_matricula('373010')
    lista << Funcionario.find_by_matricula('499820')
    lista << Funcionario.find_by_matricula('315982')
    lista << Funcionario.find_by_matricula('620440')
    lista << Funcionario.find_by_matricula('431818')
    lista << Funcionario.find_by_matricula('317470')
    lista << Funcionario.find_by_matricula('429856')
    lista << Funcionario.find_by_matricula('432423')
    lista << Funcionario.find_by_matricula('313416')
    lista << Funcionario.find_by_matricula('291072')
    lista << Funcionario.find_by_matricula('460460')
    lista << Funcionario.find_by_matricula('498998')
    lista << Funcionario.find_by_matricula('293741')
    lista << Funcionario.find_by_matricula('395722')
    lista << Funcionario.find_by_matricula('327786')
    lista << Funcionario.find_by_matricula('326690')
    lista << Funcionario.find_by_matricula('254622')
    lista << Funcionario.find_by_matricula('432580')
    lista << Funcionario.find_by_matricula('411914')
    lista << Funcionario.find_by_matricula('253529')
    lista << Funcionario.find_by_matricula('411825')
    lista << Funcionario.find_by_matricula('250422')
    lista << Funcionario.find_by_matricula('289167')
    lista << Funcionario.find_by_matricula('500267')
    lista << Funcionario.find_by_matricula('326976')
    lista << Funcionario.find_by_matricula('432644')
    lista << Funcionario.find_by_matricula('287180')
    lista << Funcionario.find_by_matricula('253030')
    lista << Funcionario.find_by_matricula('316261')
    lista << Funcionario.find_by_matricula('323705')
    lista << Funcionario.find_by_matricula('436780')
    lista << Funcionario.find_by_matricula('620548')
    lista << Funcionario.find_by_matricula('635197')
    lista << Funcionario.find_by_matricula('362450')
    lista << Funcionario.find_by_matricula('250090')
    lista << Funcionario.find_by_matricula('416258')
    lista << Funcionario.find_by_matricula('293563')
    lista << Funcionario.find_by_matricula('326887')
    lista << Funcionario.find_by_matricula('247618')
    lista << Funcionario.find_by_matricula('416037')
    lista << Funcionario.find_by_matricula('412384')
    lista << Funcionario.find_by_matricula('408298')
    lista << Funcionario.find_by_matricula('497517')
    lista << Funcionario.find_by_matricula('248126')
    lista << Funcionario.find_by_matricula('289698')
    lista << Funcionario.find_by_matricula('365203')
    lista << Funcionario.find_by_matricula('293776')
    lista << Funcionario.find_by_matricula('288080')
    lista << Funcionario.find_by_matricula('620483')
    lista << Funcionario.find_by_matricula('635189')
    lista << Funcionario.find_by_matricula('407887')
    lista << Funcionario.find_by_matricula('434965')
    lista << Funcionario.find_by_matricula('287156')
    lista << Funcionario.find_by_matricula('439762')
    lista << Funcionario.find_by_matricula('313050')
    lista << Funcionario.find_by_matricula('289850')
    lista << Funcionario.find_by_matricula('313980')
    lista << Funcionario.find_by_matricula('993344')
    lista << Funcionario.find_by_matricula('343153')
    lista << Funcionario.find_by_matricula('416096')
    lista << Funcionario.find_by_matricula('327190')
    lista << Funcionario.find_by_matricula('254673')
    lista << Funcionario.find_by_matricula('318825')
    lista << Funcionario.find_by_matricula('619167')
    lista << Funcionario.find_by_matricula('286699')
    lista << Funcionario.find_by_matricula('282421')
    lista << Funcionario.find_by_matricula('314889')
    lista << Funcionario.find_by_matricula('317390')
    lista << Funcionario.find_by_matricula('326607')
    lista << Funcionario.find_by_matricula('614173')
    lista << Funcionario.find_by_matricula('286079')
    lista << Funcionario.find_by_matricula('406465')
    lista << Funcionario.find_by_matricula('431036')
    lista << Funcionario.find_by_matricula('314463')
    lista << Funcionario.find_by_matricula('247871')
    lista << Funcionario.find_by_matricula('412945')
    lista << Funcionario.find_by_matricula('327778')
    lista << Funcionario.find_by_matricula('421626')
    lista << Funcionario.find_by_matricula('326860')
    lista << Funcionario.find_by_matricula('360538')
    lista << Funcionario.find_by_matricula('937770')
    lista << Funcionario.find_by_matricula('360473')
    lista << Funcionario.find_by_matricula('612677')
    lista << Funcionario.find_by_matricula('629561')
    lista << Funcionario.find_by_matricula('614130')
    lista << Funcionario.find_by_matricula('318701')
    lista << Funcionario.find_by_matricula('288802')
    lista << Funcionario.find_by_matricula('365580')
    lista << Funcionario.find_by_matricula('360678')
    lista << Funcionario.find_by_matricula('315338')
    lista << Funcionario.find_by_matricula('316202')
    lista << Funcionario.find_by_matricula('431168')
    lista << Funcionario.find_by_matricula('316148')
    lista << Funcionario.find_by_matricula('360147')
    lista << Funcionario.find_by_matricula('444413')
    lista << Funcionario.find_by_matricula('614726')
    lista << Funcionario.find_by_matricula('290424')
    lista << Funcionario.find_by_matricula('315745')
    lista << Funcionario.find_by_matricula('499013')
    lista << Funcionario.find_by_matricula('328006')
    lista << Funcionario.find_by_matricula('286320')
    lista << Funcionario.find_by_matricula('317691')
    lista << Funcionario.find_by_matricula('315923')
    lista << Funcionario.find_by_matricula('854832')
    lista << Funcionario.find_by_matricula('252808')
    lista << Funcionario.find_by_matricula('401668')
    lista << Funcionario.find_by_matricula('328014')
    lista << Funcionario.find_by_matricula('289434')
    lista << Funcionario.find_by_matricula('433110')
    lista << Funcionario.find_by_matricula('433101')
    lista << Funcionario.find_by_matricula('293504')
    lista << Funcionario.find_by_matricula('887960')
    lista << Funcionario.find_by_matricula('409855')
    lista << Funcionario.find_by_matricula('282219')
    lista << Funcionario.find_by_matricula('620939')
    lista << Funcionario.find_by_matricula('421553')
    lista << Funcionario.find_by_matricula('325791')
    lista << Funcionario.find_by_matricula('317357')
    lista << Funcionario.find_by_matricula('620823')
    lista << Funcionario.find_by_matricula('246638')
    lista << Funcionario.find_by_matricula('620777')
    lista << Funcionario.find_by_matricula('329444')
    lista << Funcionario.find_by_matricula('686743')
    lista << Funcionario.find_by_matricula('414107')
    lista << Funcionario.find_by_matricula('323187')
    lista << Funcionario.find_by_matricula('495034')
    lista << Funcionario.find_by_matricula('285307')
    lista << Funcionario.find_by_matricula('629618')
    lista << Funcionario.find_by_matricula('409316')
    lista << Funcionario.find_by_matricula('293652')
    lista << Funcionario.find_by_matricula('418722')
    lista << Funcionario.find_by_matricula('314633')
    lista << Funcionario.find_by_matricula('359637')
    lista << Funcionario.find_by_matricula('887870')
    lista << Funcionario.find_by_matricula('612863')
    lista << Funcionario.find_by_matricula('497398')
    lista << Funcionario.find_by_matricula('429023')
    lista << Funcionario.find_by_matricula('334146')
    lista << Funcionario.find_by_matricula('614181')
    lista << Funcionario.find_by_matricula('319074')
    lista << Funcionario.find_by_matricula('318558')
    lista << Funcionario.find_by_matricula('283118')
    lista << Funcionario.find_by_matricula('975893')
    lista << Funcionario.find_by_matricula('315893')
    lista << Funcionario.find_by_matricula('414760')
    lista << Funcionario.find_by_matricula('612839')
    lista << Funcionario.find_by_matricula('337684')
    lista << Funcionario.find_by_matricula('434400')
    lista << Funcionario.find_by_matricula('313564')
    lista << Funcionario.find_by_matricula('557544')
    lista << Funcionario.find_by_matricula('281360')
    lista << Funcionario.find_by_matricula('327514')
    lista << Funcionario.find_by_matricula('365157')
    lista << Funcionario.find_by_matricula('360651')
    lista << Funcionario.find_by_matricula('250449')
    lista << Funcionario.find_by_matricula('286249')
    lista << Funcionario.find_by_matricula('249858')
    lista << Funcionario.find_by_matricula('614122')
    lista << Funcionario.find_by_matricula('622443')
    lista << Funcionario.find_by_matricula('418706')
    lista << Funcionario.find_by_matricula('429651')
    lista << Funcionario.find_by_matricula('436879')
    lista << Funcionario.find_by_matricula('287105')
    lista << Funcionario.find_by_matricula('289396')
    lista << Funcionario.find_by_matricula('429783')
    lista << Funcionario.find_by_matricula('249637')
    lista << Funcionario.find_by_matricula('313912')
    lista << Funcionario.find_by_matricula('406368')
    lista << Funcionario.find_by_matricula('360180')
    lista << Funcionario.find_by_matricula('284114')
    lista << Funcionario.find_by_matricula('284157')
    lista << Funcionario.find_by_matricula('313750')
    lista << Funcionario.find_by_matricula('407461')
    lista << Funcionario.find_by_matricula('434213')
    lista << Funcionario.find_by_matricula('253200')
    lista << Funcionario.find_by_matricula('439258')
    lista << Funcionario.find_by_matricula('284327')
    lista << Funcionario.find_by_matricula('293288')
    lista << Funcionario.find_by_matricula('254495')
    lista << Funcionario.find_by_matricula('614246')
    lista << Funcionario.find_by_matricula('328952')
    lista << Funcionario.find_by_matricula('412554')
    lista << Funcionario.find_by_matricula('328944')
    lista << Funcionario.find_by_matricula('407569')
    lista << Funcionario.find_by_matricula('614211')
    lista << Funcionario.find_by_matricula('431281')
    lista << Funcionario.find_by_matricula('362999')
    lista << Funcionario.find_by_matricula('496200')
    lista << Funcionario.find_by_matricula('498653')
    lista << Funcionario.find_by_matricula('431257')
    lista << Funcionario.find_by_matricula('629383')
    lista << Funcionario.find_by_matricula('286796')
    lista << Funcionario.find_by_matricula('280984')
    lista << Funcionario.find_by_matricula('415740')
    lista << Funcionario.find_by_matricula('247502')
    lista << Funcionario.find_by_matricula('328979')
    lista << Funcionario.find_by_matricula('245810')
    lista << Funcionario.find_by_matricula('284076')
    lista << Funcionario.find_by_matricula('249416')
    lista << Funcionario.find_by_matricula('317225')
    lista << Funcionario.find_by_matricula('614009')
    lista << Funcionario.find_by_matricula('253367')
    lista << Funcionario.find_by_matricula('314412')
    lista << Funcionario.find_by_matricula('313807')
    lista << Funcionario.find_by_matricula('412538')
    lista << Funcionario.find_by_matricula('416630')
    lista << Funcionario.find_by_matricula('315834')
    lista << Funcionario.find_by_matricula('324531')
    lista << Funcionario.find_by_matricula('613991')
    lista << Funcionario.find_by_matricula('436887')
    lista << Funcionario.find_by_matricula('415693')
    lista << Funcionario.find_by_matricula('359793')
    lista << Funcionario.find_by_matricula('629430')
    lista << Funcionario.find_by_matricula('290491')
    lista << Funcionario.find_by_matricula('886459')
    lista << Funcionario.find_by_matricula('629839')
    lista << Funcionario.find_by_matricula('635596')
    lista << Funcionario.find_by_matricula('620327')
    lista << Funcionario.find_by_matricula('328936')
    lista << Funcionario.find_by_matricula('635570')
    lista << Funcionario.find_by_matricula('334936')
    lista << Funcionario.find_by_matricula('635561')
    lista << Funcionario.find_by_matricula('635553')
    lista << Funcionario.find_by_matricula('327336')
    lista << Funcionario.find_by_matricula('416789')
    lista << Funcionario.find_by_matricula('399469')
    lista << Funcionario.find_by_matricula('432369')
    lista << Funcionario.find_by_matricula('284297')
    lista << Funcionario.find_by_matricula('324612')
    lista << Funcionario.find_by_matricula('286338')
    lista << Funcionario.find_by_matricula('291552')
    lista << Funcionario.find_by_matricula('287504')
    lista << Funcionario.find_by_matricula('287270')
    lista << Funcionario.find_by_matricula('293431')
    lista << Funcionario.find_by_matricula('286389')
    lista << Funcionario.find_by_matricula('406953')
    lista << Funcionario.find_by_matricula('619779')
    lista << Funcionario.find_by_matricula('319171')
    lista << Funcionario.find_by_matricula('281948')
    lista << Funcionario.find_by_matricula('327433')
    lista << Funcionario.find_by_matricula('284190')
    lista << Funcionario.find_by_matricula('288861')
    lista << Funcionario.find_by_matricula('431249')
    lista << Funcionario.find_by_matricula('635537')
    lista << Funcionario.find_by_matricula('620025')
    lista << Funcionario.find_by_matricula('495743')
    lista << Funcionario.find_by_matricula('324574')
    lista << Funcionario.find_by_matricula('436917')
    lista << Funcionario.find_by_matricula('619841')
    lista << Funcionario.find_by_matricula('284050')
    lista << Funcionario.find_by_matricula('409618')
    lista << Funcionario.find_by_matricula('360171')
    lista << Funcionario.find_by_matricula('323640')
    lista << Funcionario.find_by_matricula('247251')
    lista << Funcionario.find_by_matricula('283339')
    lista << Funcionario.find_by_matricula('453773')
    lista << Funcionario.find_by_matricula('254665')
    lista << Funcionario.find_by_matricula('363111')
    lista << Funcionario.find_by_matricula('289205')
    lista << Funcionario.find_by_matricula('327417')
    lista << Funcionario.find_by_matricula('436925')
    lista << Funcionario.find_by_matricula('635316')
    lista << Funcionario.find_by_matricula('406597')
    lista << Funcionario.find_by_matricula('635413')
    lista << Funcionario.find_by_matricula('288373')
    lista << Funcionario.find_by_matricula('286788')
    lista << Funcionario.find_by_matricula('612928')
    lista << Funcionario.find_by_matricula('412660')
    lista << Funcionario.find_by_matricula('412511')
    lista << Funcionario.find_by_matricula('497380')
    lista << Funcionario.find_by_matricula('293377')
    lista << Funcionario.find_by_matricula('291129')
    lista << Funcionario.find_by_matricula('497266')
    lista << Funcionario.find_by_matricula('288047')
    lista << Funcionario.find_by_matricula('620050')
    lista << Funcionario.find_by_matricula('433012')
    lista << Funcionario.find_by_matricula('436941')
    lista << Funcionario.find_by_matricula('314161')
    lista << Funcionario.find_by_matricula('432547')
    lista << Funcionario.find_by_matricula('322571')
    lista << Funcionario.find_by_matricula('281972')
    lista << Funcionario.find_by_matricula('324680')
    lista << Funcionario.find_by_matricula('620890')
    lista << Funcionario.find_by_matricula('318191')
    lista << Funcionario.find_by_matricula('422142')
    lista << Funcionario.find_by_matricula('432865')
    lista << Funcionario.find_by_matricula('409065')
    lista << Funcionario.find_by_matricula('494526')
    lista << Funcionario.find_by_matricula('283002')
    lista << Funcionario.find_by_matricula('285870')
    lista << Funcionario.find_by_matricula('249319')
    lista << Funcionario.find_by_matricula('433020')
    lista << Funcionario.find_by_matricula('399442')
    lista << Funcionario.find_by_matricula('245500')
    lista << Funcionario.find_by_matricula('397334')
    lista << Funcionario.find_by_matricula('412074')
    lista << Funcionario.find_by_matricula('431303')
    lista << Funcionario.find_by_matricula('254592')
    lista << Funcionario.find_by_matricula('246786')
    lista << Funcionario.find_by_matricula('313475')
    lista << Funcionario.find_by_matricula('411507')
    lista << Funcionario.find_by_matricula('322458')
    lista << Funcionario.find_by_matricula('312010')
    lista << Funcionario.find_by_matricula('854115')
    lista << Funcionario.find_by_matricula('436984')
    lista << Funcionario.find_by_matricula('284130')
    lista << Funcionario.find_by_matricula('395307')
    lista << Funcionario.find_by_matricula('494496')
    lista << Funcionario.find_by_matricula('314285')
    lista << Funcionario.find_by_matricula('246280')
    lista << Funcionario.find_by_matricula('286800')
    lista << Funcionario.find_by_matricula('283908')
    lista << Funcionario.find_by_matricula('281352')
    lista << Funcionario.find_by_matricula('621323')
    lista << Funcionario.find_by_matricula('290416')
    lista << Funcionario.find_by_matricula('439215')
    lista << Funcionario.find_by_matricula('329002')
    lista << Funcionario.find_by_matricula('313017')
    lista << Funcionario.find_by_matricula('407100')
    lista << Funcionario.find_by_matricula('500275')
    lista << Funcionario.find_by_matricula('249955')
    lista << Funcionario.find_by_matricula('621226')
    lista << Funcionario.find_by_matricula('317462')
    lista << Funcionario.find_by_matricula('882984')
    lista << Funcionario.find_by_matricula('851450')
    lista << Funcionario.find_by_matricula('319317')
    lista << Funcionario.find_by_matricula('415391')
    lista << Funcionario.find_by_matricula('254240')
    lista << Funcionario.find_by_matricula('853399')
    lista << Funcionario.find_by_matricula('620998')
    lista << Funcionario.find_by_matricula('431826')
    lista << Funcionario.find_by_matricula('431397')
    lista << Funcionario.find_by_matricula('620955')
    lista << Funcionario.find_by_matricula('415960')
    lista << Funcionario.find_by_matricula('629227')
    lista << Funcionario.find_by_matricula('431370')
    lista << Funcionario.find_by_matricula('935948')
    lista << Funcionario.find_by_matricula('408751')
    lista << Funcionario.find_by_matricula('318043')
    lista << Funcionario.find_by_matricula('253456')
    lista << Funcionario.find_by_matricula('629243')
    lista << Funcionario.find_by_matricula('316911')
    lista << Funcionario.find_by_matricula('431362')
    lista << Funcionario.find_by_matricula('317233')
    lista << Funcionario.find_by_matricula('330183')
    lista << Funcionario.find_by_matricula('284092')
    lista << Funcionario.find_by_matricula('246913')
    lista << Funcionario.find_by_matricula('429449')
    lista << Funcionario.find_by_matricula('619647')
    lista << Funcionario.find_by_matricula('621250')
    lista << Funcionario.find_by_matricula('408336')
    lista << Funcionario.find_by_matricula('322415')
    lista << Funcionario.find_by_matricula('635510')
    lista << Funcionario.find_by_matricula('616826')
    lista << Funcionario.find_by_matricula('422240')
    lista << Funcionario.find_by_matricula('401765')
    lista << Funcionario.find_by_matricula('418773')
    lista << Funcionario.find_by_matricula('616850')
    lista << Funcionario.find_by_matricula('621358')
    lista << Funcionario.find_by_matricula('612588')
    lista << Funcionario.find_by_matricula('313955')
    lista << Funcionario.find_by_matricula('615676')
    lista << Funcionario.find_by_matricula('329045')
    lista << Funcionario.find_by_matricula('497070')
    lista << Funcionario.find_by_matricula('293911')
    lista << Funcionario.find_by_matricula('282510')
    lista << Funcionario.find_by_matricula('429732')
    lista << Funcionario.find_by_matricula('312282')
    lista << Funcionario.find_by_matricula('290394')
    lista << Funcionario.find_by_matricula('429791')
    lista << Funcionario.find_by_matricula('621315')
    lista << Funcionario.find_by_matricula('293890')
    lista << Funcionario.find_by_matricula('318698')
    lista << Funcionario.find_by_matricula('414921')
    lista << Funcionario.find_by_matricula('319104')
    lista << Funcionario.find_by_matricula('409464')
    lista << Funcionario.find_by_matricula('281018')
    lista << Funcionario.find_by_matricula('248797')
    lista << Funcionario.find_by_matricula('329070')
    lista << Funcionario.find_by_matricula('498947')
    lista << Funcionario.find_by_matricula('293253')
    lista << Funcionario.find_by_matricula('249629')
    lista << Funcionario.find_by_matricula('325252')
    lista << Funcionario.find_by_matricula('439720')
    lista << Funcionario.find_by_matricula('621080')
    lista << Funcionario.find_by_matricula('612634')
    lista << Funcionario.find_by_matricula('315737')
    lista << Funcionario.find_by_matricula('620009')
    lista << Funcionario.find_by_matricula('411582')
    lista << Funcionario.find_by_matricula('629138')
    lista << Funcionario.find_by_matricula('437042')
    lista << Funcionario.find_by_matricula('408409')
    lista << Funcionario.find_by_matricula('432750')
    lista << Funcionario.find_by_matricula('283495')
    lista << Funcionario.find_by_matricula('316580')
    lista << Funcionario.find_by_matricula('365238')
    lista << Funcionario.find_by_matricula('327867')
    lista << Funcionario.find_by_matricula('327816')
    lista << Funcionario.find_by_matricula('321770')
    lista << Funcionario.find_by_matricula('854344')
    lista << Funcionario.find_by_matricula('619698')
    lista << Funcionario.find_by_matricula('431796')
    lista << Funcionario.find_by_matricula('401196')
    lista << Funcionario.find_by_matricula('635472')
    lista << Funcionario.find_by_matricula('251216')
    lista << Funcionario.find_by_matricula('429406')
    lista << Funcionario.find_by_matricula('285188')
    lista << Funcionario.find_by_matricula('246298')
    lista << Funcionario.find_by_matricula('414336')
    lista << Funcionario.find_by_matricula('316830')
    lista << Funcionario.find_by_matricula('281824')
    lista << Funcionario.find_by_matricula('415910')
    lista << Funcionario.find_by_matricula('327840')
    lista << Funcionario.find_by_matricula('294152')
    lista << Funcionario.find_by_matricula('401900')
    lista << Funcionario.find_by_matricula('284203')
    lista << Funcionario.find_by_matricula('1126024')
    lista << Funcionario.find_by_matricula('245313')
    lista << Funcionario.find_by_matricula('439185')
    lista << Funcionario.find_by_matricula('284084')
    lista << Funcionario.find_by_matricula('328367')
    lista << Funcionario.find_by_matricula('328340')
    lista << Funcionario.find_by_matricula('246263')
    lista << Funcionario.find_by_matricula('252239')
    lista << Funcionario.find_by_matricula('321079')
    lista << Funcionario.find_by_matricula('315176')
    lista << Funcionario.find_by_matricula('315290')
    lista << Funcionario.find_by_matricula('406511')
    lista << Funcionario.find_by_matricula('332739')
    lista << Funcionario.find_by_matricula('328359')
    lista << Funcionario.find_by_matricula('431443')
    lista << Funcionario.find_by_matricula('428787')
    lista << Funcionario.find_by_matricula('318531')
    lista << Funcionario.find_by_matricula('424358')
    lista << Funcionario.find_by_matricula('329134')
    lista << Funcionario.find_by_matricula('249106')
    lista << Funcionario.find_by_matricula('290408')
    lista << Funcionario.find_by_matricula('325325')
    lista << Funcionario.find_by_matricula('328405')
    lista << Funcionario.find_by_matricula('291145')
    lista << Funcionario.find_by_matricula('620912')
    lista << Funcionario.find_by_matricula('621196')
    lista << Funcionario.find_by_matricula('436666')
    lista << Funcionario.find_by_matricula('431435')
    lista << Funcionario.find_by_matricula('428779')
    lista << Funcionario.find_by_matricula('316571')
    lista << Funcionario.find_by_matricula('627372')
    lista << Funcionario.find_by_matricula('434418')
    lista << Funcionario.find_by_matricula('994260')
    lista << Funcionario.find_by_matricula('255130')
    lista << Funcionario.find_by_matricula('436674')
    lista << Funcionario.find_by_matricula('406589')
    lista << Funcionario.find_by_matricula('412600')
    lista << Funcionario.find_by_matricula('368040')
    lista << Funcionario.find_by_matricula('619060')
    lista << Funcionario.find_by_matricula('315249')
    lista << Funcionario.find_by_matricula('247669')
    lista << Funcionario.find_by_matricula('318264')
    lista << Funcionario.find_by_matricula('431842')
    lista << Funcionario.find_by_matricula('332917')
    lista << Funcionario.find_by_matricula('251810')
    lista << Funcionario.find_by_matricula('312525')
    lista << Funcionario.find_by_matricula('328839')
    lista << Funcionario.find_by_matricula('300209')
    lista << Funcionario.find_by_matricula('362344')
    lista << Funcionario.find_by_matricula('286257')
    lista << Funcionario.find_by_matricula('432873')
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

  # def pessoa_params
  #   params.require(:pessoa).permit!
  # end

end
