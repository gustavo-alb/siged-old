# -*- encoding : utf-8 -*-
class FuncionariosController < ApplicationController
  # GET /funcionarios
  # GET /funcionarios.xml
  before_filter :pessoa,:except=>[:folha,:relatorio_por_disciplina,:comissionados,:cargo,:distrito,:diretor,:categoria]
  before_filter :dados_essenciais,:except=>[:comissionados]
  def index
    #@search = Funcionario.da_pessoa(params[:pessoa_id]).scoped_search(params[:search])
    @funcionarios = Funcionario.da_pessoa(@pessoa.id).all.paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @funcionarios }
    end
  end

  def destino
    @destinos = TipoDestino.all.collect{|t|[t.nome,t.id]}
    render :partial=>'tipo'
  end

  def verificar_funcionario
    @funcionario = Funcionario.find(params[:funcionario_id])
    @funcionario.verificado = true
    if @funcionario.save!(:validate=>false)
      respond_to do |format|
       format.js {render "verificar_funcionario",:locals=>{:f=>@funcionario,:p=>@funcionario.pessoa}}
     end
   end
 end

 def desverificar_funcionario
  @funcionario = Funcionario.find(params[:funcionario_id])
  @funcionario.verificado = false
  if @funcionario.save!(:validate=>false)
    respond_to do |format|
      format.js {render "desverificar_funcionario",:locals=>{:f=>@funcionario,:p=>@funcionario.pessoa}}
    end
  end
end

def ativar_funcionario
  @funcionario = Funcionario.find(params[:funcionario_id])
  @funcionario.ativo = true
  if @funcionario.save!(:validate=>false)
    render :update do |page|
     format.js {render("desverificar_funcionario",:locals=>{:f=>@funcionario,:p=>@funcionario.pessoa})}
   end
 end
end

def desativar_funcionario
  @funcionario = Funcionario.find(params[:funcionario_id])
  @funcionario.ativo = false
  if @funcionario.save!(:validate=>false)
    render :update do |page|
      page.replace_html "ativo-#{@funcionario.matricula}", :partial=>"ativar_funcionario"
    end
  end
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
    @mes = @data.month
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
      if @categoria.nome=="Estado Novo" or @categoria.nome=="Contrato Administrativo" or @categoria.nome=="Concurso de 2012"
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

  # def carta
  #   @funcionario = Funcionario.find(params[:funcionario_id])
  #   @pessoa = Pessoa.find(params[:pessoa_id])
  #   @lotacao = Lotacao.find(params[:lotacao])
  #   prazo = @lotacao.data_lotacao+3.day
  #   @prazo=prazo.to_date.to_s_br
  #   @processo = @lotacao.processos.last
  #   #file_name=Rails.root.join("public/cartas/#{@funcionario.pessoa.nome}", "#{@funcionario.pessoa.nome.downcase.parameterize}#{@processo.processo.parameterize}.pdf")
  #   #if File.exist?(file_name)
  #   # send_file(file_name,:type=>"application/pdf" )
  #  #else
  #  respond_to do |format|
  #      ## format.html # show.html.erb
  #    #  if !File.exist?(Rails.root.join("public/cartas/#{@funcionario.pessoa.nome}"))
  #     #   Dir.mkdir(Rails.root.join("public/cartas/#{@funcionario.pessoa.nome}"))
  #     # end
  #     format.pdf do
  #       render :pdf =>"#{@funcionario.pessoa.nome.downcase.parameterize}#{@processo.processo.parameterize}",
  #       :layout => "pdf", # OPTIONAL
  #       :wkhtmltopdf=>"/usr/bin/wkhtmltopdf",
  #       :margin=>{:top=>5,:left=>5,:right=>5,:bottom=>40},
  #       :footer=>{:html =>{:template => 'shared/lotacao_footer.pdf.erb'}},
  #       :zoom => 0.8 ,
  #       :orientation => 'Portrait'
  #   #  end
  #     # @carta = Carta.create(:funcionario_id=>@funcionario.id, :lotacao_id=>@lotacao.id, :carta_file_name=> "#{filename}.pdf")
  #   end
  # end
  # end

  # confirmar essa deprecação pela nova_carta
  def carta
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = Pessoa.find(params[:pessoa_id])
    @lotacao = Lotacao.find(params[:lotacao])
    prazo = @lotacao.data_lotacao+3.day
    @prazo=prazo.to_date.to_s_br
    @processo = @lotacao.processos.last
    @usuario = @lotacao.usuario
    File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
    carta = ODFReport::Report.new("#{Rails.public_path}/modelos/carta.odt") do |r|
      r.add_field "NOME", @pessoa.nome
      r.add_field "CPF", @pessoa.cpf
      r.add_field "MATRICULA", @funcionario.matricula
      r.add_field "QUADRO",  "#{view_context.detalhes(@funcionario.categoria)}"
      r.add_field "CARGO_E_MATRICULA", view_context.cargo_e_matricula(@funcionario)
      r.add_field "JORNADA",view_context.jornada(@funcionario.nivel)
      r.add_field "NUMERO", @processo.processo
      r.add_field "DATA",@lotacao.data_lotacao.to_s_br
      r.add_field "HORA",(@lotacao.created_at+3.hours).strftime("%H:%M")
      r.add_field "DESTINO",view_context.detalhes(@lotacao.destino)
      # lotacao_detalhes(f,"detalhado")
      # r.add_field "ANTERIOR",view_context.l_ant(@funcionario)
      r.add_field "ANTERIOR",view_context.lotacao_anterior(@funcionario)


      # meu
      r.add_field "NOVO_ANTERIOR",view_context.l_ant(@funcionario)
      r.add_field "DATAAPRESENTACAO", @lotacao.data_lotacao+3.days
      r.add_field "USER", @usuario.name
      # primeiro_ultimo_nome
      r.add_field "DISCIPLINACONTRATACAO", view_context.cargo_disciplina(@funcionario)
      r.add_field "MUNICIPIO", view_context.municipio_destino(@lotacao.destino)
      r.add_field "MUNICIPIO_DESTINO", view_context.municipio_destino(@lotacao.destino)
      r.add_field "OBSERVACAO",@lotacao.motivo
      r.add_image :codigo_barras,  "/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png"
    end
    arquivo_carta = carta.generate("/tmp/carta-#{@funcionario.matricula}.odt")
    system "unoconv -f pdf /tmp/carta-#{@funcionario.matricula}.odt"
    f = File.open("/tmp/carta-#{@funcionario.matricula}.pdf",'r')
    send_file(f,:filename=>"Carta de Apresentaçao - #{@pessoa.nome} - #{@funcionario.matricula}.pdf",:content_type=>"application/pdf")
  end
  # confirmar essa deprecação pela nova_carta

  def nova_carta
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = Pessoa.find(params[:pessoa_id])
    @lotacao = Lotacao.find(params[:lotacao])
    prazo = @lotacao.data_lotacao+3.day
    @prazo=prazo.to_date.to_s_br
    @processo = @lotacao.processos.last
    @usuario = @lotacao.usuario
    File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
    carta = ODFReport::Report.new("#{Rails.public_path}/modelos/nova_carta.odt") do |r|
      r.add_field "NOME", @pessoa.nome
      r.add_field "NOME_E_CPF", view_context.nome_e_cpf(@funcionario)
      r.add_field "CPF", @pessoa.cpf
      r.add_field "MATRICULA", @funcionario.matricula
      r.add_field "QUADRO",  "#{view_context.detalhes(@funcionario.categoria)}"
      r.add_field "CARGO_E_MATRICULA", view_context.cargo_e_matricula(@funcionario)
      r.add_field "ENQUADRAMENTO_FUNCIONAL", view_context.enquadramento_funcional(@funcionario)
      r.add_field "JORNADA",view_context.jornada(@funcionario.nivel)
      r.add_field "NUMERO", @processo.processo
      r.add_field "DATA",@lotacao.data_lotacao.to_s_br
      r.add_field "HORA",(@lotacao.created_at+3.hours).strftime("%H:%M")
      # r.add_field "DESTINO",view_context.detalhes(@lotacao.destino)
      # lotacao_detalhes(f,"detalhado")
      # r.add_field "ANTERIOR",view_context.l_ant(@funcionario)
      r.add_field "DESTINO_ANTERIOR",view_context.lotacao_anterior(@funcionario)
      r.add_field "DESTINO_ATUAL",view_context.lotacao_atual(@lotacao)

      # meu
      r.add_field "NOVO_ANTERIOR",view_context.l_ant(@funcionario)
      r.add_field "DATAAPRESENTACAO", @lotacao.data_lotacao+3.days
      r.add_field "USER", @usuario.name
      # primeiro_ultimo_nome
      r.add_field "DISCIPLINACONTRATACAO", view_context.cargo_disciplina(@funcionario)
      r.add_field "MUNICIPIO", view_context.municipio_destino(@lotacao.destino)
      r.add_field "MUNICIPIO_DESTINO", view_context.municipio_destino(@lotacao.destino)
      r.add_field "OBSERVACAO",@lotacao.motivo
      r.add_image :codigo_barras,  "/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png"
    end
    arquivo_carta = carta.generate("/tmp/carta-#{@funcionario.matricula}.odt")
    system "unoconv -f pdf /tmp/carta-#{@funcionario.matricula}.odt"
    f = File.open("/tmp/carta-#{@funcionario.matricula}.pdf",'r')
    send_file(f,:filename=>"Carta de Apresentaçao - #{@pessoa.nome} - #{@funcionario.matricula}.pdf",:content_type=>"application/pdf")
  end

  def relatorio_sem_categoria
    pasta = Workbook::Book.open("public/modelos/relatorio_sem_categoria.xls")
    planilha = pasta.sheet.table
    linha_modelo = planilha[1]
    @funcionarios = Funcionario.sem_categoria.sort_by{|f|f.pessoa.nome}
    @funcionarios.each.with_index(2) do |f,i|
      planilha << linha_modelo.clone
      planilha[i][0] = f.pessoa.nome
      planilha[i][1] = view_context.detalhes(f.categoria)
      planilha[i][2] = f.pessoa.cpf
      planilha[i][3] = f.pessoa.rg
      planilha[i][4] = view_context.contato_simples(f.pessoa)
      planilha[i][5] = view_context.detalhes(f.cargo)
      planilha[i][6] = view_context.municipio(f).upcase
      planilha[i][7] = view_context.lotacao(f)
    end
    planilha.delete(linha_modelo)
    arquivo = File.open("/tmp/relatorio-nd-#{Time.now.strftime("%d-%m-%Y-%H-%M-%S")}.xls",'w')
    pasta.write_to_xls("#{arquivo.path}")
    send_file(arquivo.path,:filename=>"Relatório Servidores sem Categoria Funcional.xls",:type=>"application/vnd.ms-excel")
  end

  def gerar_contrato
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = Pessoa.find(params[:pessoa_id])
    # @contrato = Contrato.find_by_lotacao_id(@lotacao.id)||Contrato.create(:lotacao_id=>@lotacao.id,:funcionario_id=>@funcionario.id,:numero=>Contrato.count+1)

    # File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
    if ["ASSISTENTE ADMINISTRATIVO","ANALISTA ADMINISTRATIVO"].include?(@funcionario.cargo.nome)
      @modelo = "#{Rails.public_path}/modelos/contrato_nm.odt"
    else
      @modelo = "#{Rails.public_path}/modelos/contrato.odt"
    end
    contrato = ODFReport::Report.new(@modelo) do |r|
      r.add_field "NOME", @pessoa.nome

      # r.add_field "CONTRATO",@contrato.numero
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
      r.add_field "MOPCAO",view_context.municipio(@funcionario)
      r.add_field "MLOTACAO",view_context.municipio_destino(@lotacao.destino)
      r.add_field "CARGO", view_context.cargo_disciplina(@funcionario)
      r.add_field "FUNCAO", view_context.cargo_disciplina(@funcionario)
      r.add_field "DATA",@funcionario.data_nomeacao.to_s_br
      r.add_field "USER", (@lotacao.usuario.name.upcase if @lotacao.usuario)
      r.add_field "ANO", Date.today.year

      # r.add_image :codigo_barras,  "/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png"
    end
    arquivo_carta = carta.generate("/tmp/carta-#{@funcionario.matricula}.odt")
    system "unoconv -f pdf /tmp/carta-#{@funcionario.matricula}.odt"
    f = File.open("/tmp/carta-#{@funcionario.matricula}.pdf",'r')
    send_file(f,:filename=>"Carta de Apresentaçao - #{@pessoa.nome} - #{@funcionario.matricula}.pdf",:content_type=>"application/pdf")
    # @funcionario = Funcionario.find(params[:id])
    # @pessoa = @funcionario.pessoa
    # # @pessoa = Pessoa.find(params[:pessoa_id])
    # # @funcionario = @pessoa.funcionarios.first
    # @lotacao = @funcionario.lotacoes.ativas.first
    # @contrato = Contrato.find_by_lotacao_id(@lotacao.id)||Contrato.create(:lotacao_id=>@lotacao.id,:funcionario_id=>@funcionario.id,:numero=>Contrato.count+1)
    # File.open("/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png", 'wb'){|f| f.write @lotacao.img_codigo }
    # if ["ASSISTENTE ADMINISTRATIVO","ANALISTA ADMINISTRATIVO"].include?(@funcionario.cargo.nome)
    #   @modelo = "#{Rails.public_path}/modelos/contrato_nm.odt"
    # else
    #   @modelo = "#{Rails.public_path}/modelos/contrato.odt"
    # end
    # contrato = ODFReport::Report.new(@modelo) do |r|
    #   r.add_field "CONTRATO",@contrato.numero
    #   r.add_field "NOME", @pessoa.nome
    #   r.add_field "NACIONALIDADE",@pessoa.nacionalidade
    #   r.add_field "ESTCIVIL",@pessoa.estado_civil
    #   r.add_field "RG",@pessoa.rg
    #   r.add_field "CPF", @pessoa.cpf
    #   r.add_field "ENDERECO", view_context.endereco(@pessoa)
    #   r.add_field "MRESID",view_context.detalhes(@pessoa.cidade)
    #   r.add_field "CEP",@pessoa.cep
    #   r.add_field "CONTATO", view_context.contato(@pessoa)
    #   r.add_field "DESTINO",view_context.lotacao(@funcionario)
    #   r.add_field "MOPCAO",view_context.municipio(@funcionario)
    #   r.add_field "MLOTACAO",view_context.municipio_destino(@lotacao.destino)
    #   r.add_field "CARGO", view_context.cargo_disciplina(@funcionario)
    #   r.add_field "FUNCAO", view_context.cargo_disciplina(@funcionario)
    #   r.add_field "DATA",@funcionario.data_nomeacao.to_s_br
    #   r.add_field "USER", (@lotacao.usuario.name.upcase if @lotacao.usuario)
    #   r.add_field "ANO", Date.today.year
    #   r.add_image :codigo_barras,  "/tmp/barcode-#{@funcionario.matricula}-#{@lotacao.id}.png"
    # # end
    # arquivo_contrato = contrato.generate("/tmp/contrato-#{@funcionario.matricula}.odt")
    # system "unoconv -f pdf /tmp/contrato-#{@funcionario.matricula}.odt"
    # f = File.open("/tmp/contrato-#{@funcionario.matricula}.pdf",'r')
    # send_file(f,:filename=>"Contrato Nº #{@contrato.numero}- #{@pessoa.nome}.pdf",:content_type=>"application/pdf")
  end

  def boletins
    @funcionario = Funcionario.find(params[:funcionario_id])
    @boletins = BoletimFuncional.do_func(@funcionario.id).all.paginate :page => params[:page], :per_page => 10
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
    @url = pessoa_funcionarios_url(@pessoa)
    @funcionario = Funcionario.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @funcionario }
    end
  end

  # GET /funcionarios/1/edit
  def edit
    @funcionario = Funcionario.find(params[:id])
    @url = pessoa_funcionario_url(@pessoa,@funcionario)
    @comissionados = @funcionario.comissionados.all
  end

  # POST /funcionarios
  # POST /funcionarios.xml
  def create
    @url = pessoa_funcionarios_url(@pessoa)
    @funcionario = Funcionario.new(params[:funcionario])
    @funcionario.pessoa=Pessoa.find_by_slug(params[:pessoa_id])
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
    @url = pessoa_funcionario_url(@pessoa,@funcionario)
    if params[:comissionado]
      if request.put?
        @comissionado = @funcionario.comissionados.create(params[:comissionado])
      end
    end
    respond_to do |format|
      if @funcionario.update_attributes(params[:funcionario])
        format.html { redirect_to(pessoa_funcionario_url(@pessoa,@funcionario), :notice => 'Funcionário atualizado com sucesso.') }
        format.xml  { head :ok }
        format.json { render json: @funcionario }
      else
        format.html { render :action => "edit" }
        format.json { render json: @funcionario }
        format.xml  { render :xml => @funcionario.errors, :status => :unprocessable_entity }
      end
    end
  end

  def relatorio_por_disciplina
    @funcionarios = Funcionario.disciplina_def.find(:all,:joins=>[:disciplina_contratacao,:pessoa],:order=>("descricao_cargos.nome asc, pessoas.nome asc"))
    relatorio = ODFReport::Report.new("#{Rails.root}/public/relatorios/disciplinas.odt") do |r|
      r.add_table("FUNCIONARIOS", @funcionarios, :header=>true) do |t|
        t.add_column(:nome) {|f| "#{f.pessoa.nome}"}
        t.add_column(:disc) {|f| "#{f.disciplina_contratacao.nome}"}
        t.add_column(:mat) {|f| "#{f.matricula}"}
      end
    end

    send_file(relatorio.generate,:filename=>"Relatório de funcionários por disciplina.odt")
  end

  def edicao_rapida
    # @funcionario = Funcionario.find(params[:id])
    @funcionario = Funcionario.find(params[:id])
    respond_to do |format|
       # @funcionario.update_attributes(params[:funcionario])
       if @funcionario.update_attributes!(params[:funcionario])
        format.js   { render :layout => false }
        puts "filho da putaaaaaaaaaaaaaa"
      else
        puts "Caraaaaaaaaaaaaaaaaaaaaaaaaaaaaalho"
      end
    end
  end

  def destroy
    @funcionario = Funcionario.find(params[:id])
    @funcionario.destroy

    respond_to do |format|
      format.html { redirect_to(pessoa_funcionarios_url(@pessoa)) }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
  def pessoa
    @pessoa = Pessoa.find_by_slug(params[:pessoa_id])
  end

  def dest(lotacao,f)
    if lotacao
      if lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
        return "#{lotacao.departamento.sigla.upcase}/#{lotacao.orgao.sigla.upcase}"
      elsif lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.escola.nil?
        return "#{lotacao.escola.nome.upcase}/#{lotacao.orgao.sigla.upcase}"
      elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
        return "#{lotacao.departamento.nome.upcase}/#{lotacao.orgao.sigla.upcase}"
      elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL"  and !lotacao.escola.nil? and lotacao.departamento.nil?
        return "#{lotacao.escola.nome.upcase}/#{lotacao.orgao.sigla.upcase}"
      elsif lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
        return "#{lotacao.orgao.sigla.upcase}"
      elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
        return "#{lotacao.orgao.sigla.upcase}"
      else
        return "#{lotacao.escola.nome.upcase}"

      end
    elsif !f.lotacao_recad.blank?
      return "#{f.lotacao_recad.upcase}"
    else
      return "NADA CADASTRADO"
    end
  end

end
