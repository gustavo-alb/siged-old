# -*- encoding : utf-8 -*-
class EscolasController < ApplicationController
  load_and_authorize_resource
  def autocomplete_escola_nome
    term = params[:term]
    escolas = Escola.where('nome ilike ? or codigo ilike ?', "%#{term}%","%#{term}%").order(:nome).all
    render :json => escolas.map { |escola| {:id => escola.id, :label => "#{escola.nome} - #{escola.municipio_nome}", :value => escola.nome, :tipo=>"Escola"} }
  end

  # GET /escolas
  # GET /escolas.xml
  before_filter :dados_essenciais#,:funcionarios
  def index
    @q = Escola.ransack(params[:q])
    @escolas = @q.result(distinct: true).order('nome ASC').paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @escolas }
    end
  end


  # GET /escolas/1
  # GET /escolas/1.xml
  def show
    @escola = Escola.find_by_slug(params[:id])
    @funcionarios = @escola.funcionarios.joins(:lotacoes).where("lotacaos.finalizada = ? and lotacaos.ativo = ?",true,true)
    #@funcionarios_por_cargo = @escola.funcionarios.joins(:lotacoes).where("lotacaos.finalizada = ? and lotacaos.ativo = ?",true,true)
    @cargos_principais = Cargo.where("id in (?)",[Cargo.find_by_nome("PEDAGOGO").id,Cargo.find_by_nome("PROFESSOR").id,Cargo.find_by_nome("ESPECIALISTA DE EDUCACAO").id,Cargo.find_by_nome("AUXILIAR EDUCACIONAL").id,Cargo.find_by_nome("CUIDADOR").id,Cargo.find_by_nome("INTERPRETE").id]).order(:nome)
    @outros_cargos = Cargo.where("id not in (?)",@cargos_principais).order(:nome)
    @funcionarios_cargos_principais = @escola.funcionarios.where("cargo_id in (?)",@cargos_principais).group_by{|t|t.cargo}
    @funcionarios_outros = @escola.funcionarios.where("cargo_id in (?)",@outros_cargos)
    @ambientes = @escola.ambientes

    @encaminhados = @escola.funcionarios.joins(:lotacoes).where("lotacaos.finalizada = ? and lotacaos.ativo = ?",false,true)
    if !@escola.ambientes.none?
      @ambiente = @escola.ambientes.find_by_nome("Sala de Aula")
      @turmas = Turma.find(:all,:joins=>[:serie,:matriz],:conditions=>["ambiente_id= ? and escola_id = ?",@ambiente.id,@escola.id],:order => 'turno,series.nome,nome')
    else
      @turmas = Turma.find_all_by_escola_id(@escola.id).sort_by{|e|e.nome}
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @escola }
    end
  end

  def ctrl_ch_resumido

    @escola = Escola.find(params[:escola_id])
    @matrizes = @escola.matrizes
    @user = User.usuario_atual
    @disciplinas = []
    if !@user.escola.nil? and @user.escola==@escola and @user.departamento.nil?
      destino = "#{@escola.nome.upcase} \n\n CONTROLE DE CARGA HORÁRIA – RESUMO GERAL"
    elsif !@user.departamento.nil? and @user.escola.nil?
      destino = "#{@escola.nome.upcase} \n\n CONTROLE DE CARGA HORÁRIA – RESUMO GERAL"
    end
    @matrizes.each do |m|
      m.disciplinas.order(:nome).each do |d|
        @disciplinas << d
      end
    end
    @disciplinas = @disciplinas.uniq
    relatorio = ODFReport::Report.new("#{Rails.root}/public/relatorios/controle_ch.odt") do |r|
      r.add_field(:destino,destino)
      r.add_field(:data,Time.now.strftime("%d/%m/%Y %T"))
      r.add_table("CH", @disciplinas, :header=>true) do |t|
        t.add_column(:disc) {|d| d.nome}
        t.add_column(:disp) {|d| @escola.calcular_oferta(d)}
        t.add_column(:dem) {|d| @escola.calcular_demanda(d)}
        t.add_column(:full) {|d| @escola.calcular_preenchido(d)}
        t.add_column(:ex) {|d| "0"}
      end
    end
    relatorio = relatorio.generate
    send_file(relatorio,:content_type=>"application/vnd.oasis.opendocument.text",:filename=>"Controle de Carga Horária.odt")
  end

  def ctrl_ch_detalhado
    @escola = Escola.find_by_slug(params[:escola_id])
    @matrizes = @escola.matrizes
    @user = User.usuario_atual
    @data = Time.now.strftime("%d/%m/%Y %T")
    if !@user.escola.nil? and @user.escola==@escola and @user.departamento.nil?
      @destino = "#{@escola.nome.upcase}"
      @titulo = "CONTROLE DE CARGA HORÁRIA – RESUMO GERAL"
    else
      @destino = "#{@user.departamento.nome.upcase}"
      @titulo = "CONTROLE DE CARGA HORÁRIA DA #{@escola.nome.upcase} – RESUMO GERAL"
    end
    @disciplinas = @escola.disciplinas
    @desocupados = @escola.funcionarios.includes(:especificacoes).where("especificar_lotacaos.id is null")
    @ambientes = @escola.ambientes.joins(:funcionarios).order(:nome).where("nome <> 'Sala de Aula'").uniq
    @template = File.open("#{Rails.public_path}/relatorios/controle_ch_detalhado.odt")
    @relatorio ="#{Rails.public_path}/relatorios/relatorio-#{Time.now.strftime("%d%m%H%M%S")}.odt"
    render_odt(@template.path.to_s,@relatorio.to_s)

    if Rails.env=="production"
      system("sudo -u www-data chmod 0777 #{@relatorio.to_s}")
    end

    @arq1 = File.open(@relatorio)
    send_file(@arq1.path,:content_type=>"application/vnd.oasis.opendocument.text",:filename=>"Controle de Carga Horária Detalhado - #{@escola.codigo}.odt")
    #@relatorio.close
  end

  def controle_turma
    @escola = Escola.find(params[:escola_id])
    @turma = @escola.turmas.find_by_nome(params[:turma])
    @especificacoes = @turma.especificacoes
    render :update do |page|
      page.visual_effect :highlight,"tab-three"
      page.replace_html "tab-three", :partial=>"controle_turma"
    end
  end

  def controle_ambiente
    @escola = Escola.find(params[:escola_id])
    @ambiente = @escola.ambientes.find_by_id(params[:ambiente])
    @especificacoes = @ambiente.especificacoes
    render :update do |page|
      page.visual_effect :highlight,"tab-six"
      page.replace_html "tab-six", :partial=>"controle_ambiente"
    end
  end

  def gerar_controle_ch
    @escola = Escola.find(params[:escola_id])
    @matrizes = @escola.matrizes
    @user = User.usuario_atual
    @disciplinas = []
    if !@user.escola.nil? and @user.escola==@escola and @user.departamento.nil?
      destino = "#{@escola.nome.upcase} \n\n CONTROLE DE CARGA HORÁRIA – RESUMO GERAL"
    elsif !@user.departamento.nil? and @user.escola.nil?
      destino = "#{@escola.nome.upcase} \n\n CONTROLE DE CARGA HORÁRIA – RESUMO GERAL"
    end
    @matrizes.each do |m|
      m.disciplinas.order(:nome).each do |d|
        @disciplinas << d
      end
    end
    @disciplinas = @disciplinas.uniq
    render :update do |page|
      page.replace_html "tab-five",:partial=>'controle_ch_resumido'
    end
  end


  def incluir_turma
    @escola = Escola.find params[:escola_id]
    if !@escola.ambientes.none?
      @ambiente = @escola.ambientes.find_by_nome("Sala de Aula")
      @matrizes = @escola.matrizes.collect{|m|[m.nome,m.id]}
      @turma = @ambiente.turmas.new
    end
    render :partial=>"turma"
  end

  def matrizes
    @escola = Escola.find_by_slug(params[:escola_id])
    if !params[:matrix].blank?
      @matriz = Matriz.find(params[:matrix])
      @series = @matriz.series.order(:nome).collect{|s|[s.nome,s.id]}.uniq
      render :partial=>"matriz"
    else
      render :nothing=>true
    end
  end

  def salvar_turma
    @escola = Escola.find(params[:escola_id])
    @ambiente = @escola.ambientes.find_by_nome("Sala de Aula")
    @turma = @ambiente.turmas.new(params[:turma])
    if @turma.save
      redirect_to("#{escola_path(@escola)}#tab-tres",:notice => "Turma criada com sucesso")
    else
      redirect_to("#{escola_path(@escola)}#tab-tres",:alert => "Turma não pode ser criada.")
    end
  end

  def excluir_turma
    @escola = Escola.find(params[:escola_id])
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @turma = @ambiente.turmas.find(params[:turma_id])
    @turmas = @ambiente.turmas.all
    if @turma.destroy
      render :update do |page|
        page.reload()
      end
    end
  end

  def listar_turmas
    @escola = Escola.find(params[:escola_id])
    @turmas = Turma.find(:all,:joins=>[:serie],:conditions=>["ambiente_id= ? and escola_id = ?",@ambiente.id,@escola.id],:order => 'turno,series.nome')
    render :update do |page|
      page.visual_effect :highlight,"tab-three"
      page.replace_html "tab-three", :partial=>"turmas"
    end
  end

  def listar_ambientes
    @escola = Escola.find(params[:escola_id])
    @ambientes = @escola.ambientes - @escola.ambientes.where(:nome=>"Sala de Aula")
    #@turmas = Turma.find(:all,:joins=>[:serie],:conditions=>["ambiente_id= ? and escola_id = ?",@ambiente.id,@escola.id],:order => 'turno,series.nome')
    render :update do |page|
      page.visual_effect :highlight,"tab-six"
      page.replace_html "tab-six", :partial=>"ambientes"
    end
  end

  def configuracoes
    @escola = Escola.find_by_slug(params[:escola_id])
    @matrizes = Matriz.find(:all,:joins=>:nivel,:order=>['niveis_ensinos.nome asc',:codigo])
    render :layout=>'facebox'
  end

  # GET /escolas/new
  # GET /escolas/new.xml
  def new
    @escola = Escola.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @escola }
    end
  end

  # GET /escolas/1/edit
  def edit
    @escola = Escola.find(params[:id])
  end

  # POST /escolas
  # POST /escolas.xml
  def create
    @escola = Escola.new(params[:escola])

    respond_to do |format|
      if @escola.save
        format.html { redirect_to(@escola, :notice => 'Escola cadastrada com sucesso.') }
        format.xml  { render :xml => @escola, :status => :created, :location => @escola }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @escola.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /escolas/1
  # PUT /escolas/1.xml
  def update
    @escola = Escola.find(params[:id])
    if !params[:notice].blank?
      notice = params[:notice]
    else
      notice = 'Escola atualizada com sucesso.'
    end
    respond_to do |format|
      if @escola.update_attributes(params[:escola])
        format.html { redirect_to(@escola, :notice => notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @escola.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /escolas/1
  # DELETE /escolas/1.xml
  def destroy
    @escola = Escola.find(params[:id])
    @escola.destroy

    respond_to do |format|
      format.html { redirect_to(escolas_url) }
      format.xml  { head :ok }
    end
  end

end
