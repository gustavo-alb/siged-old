# -*- encoding : utf-8 -*-
class PessoasController < ApplicationController
  load_and_authorize_resource
  before_filter :dados_essenciais
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





  def qualificar
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionarios = @pessoa.funcionarios.ativos
    @funcionario = @pessoa.funcionarios.first
    @departamento = Departamento.find(params[:departamento])
    @lotacoes = @pessoa.lotacoes
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        render :pdf =>"#{@funcionario.pessoa.nome.downcase.parameterize} - #{Time.now.to_s_br}",
          :layout => "pdf", # OPTIONAL
          :wkhtmltopdf=>"/usr/bin/wkhtmltopdf",
          :margin => {:top=> 0,
                      :bottom=> 30},
          #:left=> 2,
          # :right=> 3},
          :footer=>{:html =>{:template => 'pessoas/footer.pdf.erb'}},
          :zoom => 0.873 ,
          :orientation => 'Portrait'

      end
    end
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
        if params[:edicao_rapida]
          format.html { redirect_to(:back, :notice => 'Pessoa atualizada com sucesso.') }
          format.xml  { head :ok }
        else
          format.html { redirect_to(@pessoa, :notice => 'Pessoa atualizada com sucesso.') }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pessoa.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pessoas/1
  # DELETE /pessoas/1.xml
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



  # def pessoa_params
  #   params.require(:pessoa).permit!
  # end

end
