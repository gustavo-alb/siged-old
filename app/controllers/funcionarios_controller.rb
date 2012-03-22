class FuncionariosController < ApplicationController
  load_and_authorize_resource
  # GET /funcionarios
  # GET /funcionarios.xml
  before_filter :pessoa,:except=>[:folha,:comissionados,:cargo,:distrito,:diretor,:categoria]
  before_filter :dados_essenciais,:except=>:comissionados
  def index
    #@search = Funcionario.da_pessoa(params[:pessoa_id]).scoped_search(params[:search])
    @funcionarios = Funcionario.da_pessoa(@pessoa.id).all.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @funcionarios }
    end
  end

  def destino
    @destinos = TipoDestino.all.collect{|t|[t.nome,t.id]}
    render :partial=>'tipo'
  end

  def cargo
    if params[:disciplina].size>0
     @cargo = Cargo.find(params[:disciplina])
     if @cargo.tipo and @cargo.tipo.nome=="Magistério/Docência"
      render :partial=>"magisterio"
    else
      render :partial=>"sem_distritos"
    end
  else
   render :partial=>"sem_distritos"
 end
end


  # GET /funcionarios/1
  # GET /funcionarios/1.xml
  def show
    @funcionario = Funcionario.find(params[:id])
    @comissionados = @funcionario.comissionados.ativos.all
    @exoneracoes = @funcionario.comissionados.exoneracoes.all
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @funcionario }
    end
  end

  def ponto
    @data = Date.today.months_ago(10)
    @dias = (@data.at_beginning_of_month..@data.end_of_month)
    @mes =@data.month
  end

  def folha
   if params[:quadro].size>0
     @quadro = Quadro.find(params[:quadro])
     @folhas_quadro = @quadro.folhas.all.collect{|o|[o.nome,o.id]}
     if @folhas_quadro.size>0
      render :partial=>"folha"
    else
      render :partial=>"quadro_nulo"
    end
  else
   render :partial=>"quadro_nulo"
 end
end

def boletim_funcional
  @pessoa = Pessoa.find(params[:pessoa_id])
  @funcionario = Funcionario.find(params[:funcionario_id])
  render :layout=>nil
end

def categoria
 if params[:categoria].size>0
   @categoria = Categoria.find(params[:categoria])
   @municipios= Municipio.order(:nome).collect{|m|[m.nome,m.id]}
   if @categoria.nome=="Estado Novo" or @categoria.nome=="Contrato Administrativo"
    render :partial=>"municipio"
  else
    render :partial=>"sem_distritos"
  end
else
 render :partial=>"sem_distritos"
end
end

def comissionados
  @destinos = TipoDestino.all.collect{|t|[t.nome,t.id]}
  @funcionario = Funcionario.find(params[:id])
  @comissionado = @funcionario.comissionados.new
  @orgaos = Orgao.order(:nome).collect{|o|[o.sigla,o.id]}


  render :layout=>"facebox"

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

def historico
  @funcionario = Funcionario.find(params[:funcionario_id])
  @historico = @funcionario.processos
  render :layout=>"lotacoes2"
end


def qualificar
  @funcionario = Funcionario.find(params[:funcionario_id])
  @lotacoes = @funcionario.lotacoes.all
  @lotacao = @funcionario.lotacoes.last
  respond_to do |format|
   ## format.html # show.html.erb
   format.pdf do
    render :pdf =>"#{@funcionario.pessoa.nome.downcase}",
    :layout => "pdf", # OPTIONAL
    :wkhtmltopdf=>"/usr/bin/wkhtmltopdf",
    :zoom => 1.0 ,
    :orientation => 'Portrait'

  end
end
end

def carta
  @funcionario = Funcionario.find(params[:funcionario_id])
  @pessoa = Pessoa.find(params[:pessoa_id])
  @lotacao = Lotacao.em_aberto.find(params[:lotacao])
  prazo = @lotacao.data_lotacao+3.day
  @prazo=prazo.to_date.to_s_br
  @processo = @lotacao.processos.em_aberto.encaminhado.last
  #file_name=Rails.root.join("public/cartas/#{@funcionario.pessoa.nome}", "#{@funcionario.pessoa.nome.downcase.parameterize}#{@processo.processo.parameterize}.pdf")
  #if File.exist?(file_name)
  # send_file(file_name,:type=>"application/pdf" )
 #else
 respond_to do |format|
     ## format.html # show.html.erb
   #  if !File.exist?(Rails.root.join("public/cartas/#{@funcionario.pessoa.nome}"))
    #   Dir.mkdir(Rails.root.join("public/cartas/#{@funcionario.pessoa.nome}"))
    # end
    format.pdf do
      render :pdf =>"#{@funcionario.pessoa.nome.downcase.parameterize}#{@processo.processo.parameterize}",
      :layout => "pdf", # OPTIONAL
      :wkhtmltopdf=>"/usr/bin/wkhtmltopdf",
      :margin => {:top=> 0,:bottom=> 20},
      :footer=>{:html =>{:template => 'pessoas/footer.pdf.erb'}},
      :zoom => 0.8 ,
      :orientation => 'Portrait'
  #  end
    # @carta = Carta.create(:funcionario_id=>@funcionario.id, :lotacao_id=>@lotacao.id, :carta_file_name=> "#{filename}.pdf")
  end
end
end

def boletins
  @funcionario = Funcionario.find(params[:funcionario_id])
  @boletins = BoletimFuncional.do_func(@funcionario.id).all.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
end

def gerar_boletim
 @funcionario = Funcionario.find(params[:funcionario_id])
 @boletim = BoletimFuncional.new(params[:funcionario])
end

def exibir_boletim
  @funcionario = Funcionario.find(params[:funcionario_id])
  @boletim = @funcionario.boletins.find(params[:boletim_id])
  respond_to do |format|
    format.html # show.html.erb
    format.xml  { render :xml => @boletim }
  end
end

def salvar_boletim
  @funcionario = Funcionario.find(params[:funcionario_id])
  @boletim = @funcionario.boletins.new(params[:boletim_funcional])
  @boletim.mes = params[:date][:mes]
  @boletim.ano = params[:date][:ano]
  respond_to do |format|
    if @boletim.save
      format.html { redirect_to(pessoa_funcionario_boletins_url, :notice => 'Pessoa cadastrada com sucesso.') }
      format.xml  { render :xml => @boletim, :status => :created, :location => @boletim }
    else
      format.html { render :action => "new" }
      format.xml  { render :xml => @boletim.errors, :status => :unprocessable_entity }
    end
  end
end

# GET /funcionarios/new
# GET /funcionarios/new.xml
def new
  @funcionario = Funcionario.new

  respond_to do |format|
    format.html # new.html.erb
    format.xml  { render :xml => @funcionario }
  end
end

# GET /funcionarios/1/edit
def edit
  @funcionario = Funcionario.find(params[:id])
  @comissionados = @funcionario.comissionados.all
end

# POST /funcionarios
# POST /funcionarios.xml
def create
  @funcionario = Funcionario.new(params[:funcionario])
  @funcionario.pessoa_id=Pessoa.find_by_slug(params[:pessoa_id]).id
  respond_to do |format|
    if @funcionario.save
      format.html { redirect_to(pessoa_funcionario_url(@pessoa,@funcionario), :notice => 'Funcionário cadastrado com sucesso.') }
      format.xml  { render :xml => @funcionario, :status => :created, :location => @funcionario }
    else
      format.html { render :action => "new" }
      format.xml  { render :xml => @funcionario.errors, :status => :unprocessable_entity }
    end
  end
end

# PUT /funcionarios/1
# PUT /funcionarios/1.xml
def update
  @funcionario = Funcionario.find(params[:id])
  if params[:comissionado]
    if request.put?
      @comissionado = @funcionario.comissionados.create(params[:comissionado])
    end
  end
  respond_to do |format|
    if @funcionario.update_attributes(params[:funcionario])
      format.html { redirect_to(pessoa_funcionario_url(@pessoa,@funcionario), :notice => 'Funcionário atualizado com sucesso.') }
      format.xml  { head :ok }
    else
      format.html { render :action => "edit" }
      format.xml  { render :xml => @funcionario.errors, :status => :unprocessable_entity }
    end
  end
end

# DELETE /funcionarios/1
# DELETE /funcionarios/1.xml
def destroy
  @funcionario = Funcionario.find(params[:id])
  @funcionario.destroy

  respond_to do |format|
    format.html { redirect_to(pessoa_funcionarios_url(@pessoa)) }
    format.xml  { head :ok }
  end
end
private
def pessoa
  @pessoa = Pessoa.find(params[:pessoa_id])
end

end
