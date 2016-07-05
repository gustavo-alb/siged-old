# -*- encoding : utf-8 -*-
class LotacoesController < ApplicationController
  # GET /lotacaos
  # GET /lotacaos.xml
  autocomplete :escola, :nome, :full => true
  #autocomplete :departamento, :nome, :full => true
  #autocomplete :orgao, :nome, :full => true
  load_and_authorize_resource
  before_filter :funcionario,:except=>[:escolas_destino,:complementar_esp,:complementar,:auto_complete_for_escola_nome,:auto_complete_for_departamento_nome,:fator_lotacao_fisico,:disciplinas_especificacao,:sumesp,:convalidar,:salvar_especificacao,:fator_lotacao,:verifica_lotacao,:regencia,:destino,:lotacao_especial,:tipo_destino,:tipo_especificacao,:fator_lotacao_fisico,:destinos]
  before_filter :dados_essenciais,:except=>[:convalidar,:auto_complete_for_escola_nome,:auto_complete_for_departamento_nome]

  def autocomplete_departamento_nome
    term = params[:term]
    departamentos = Departamento.where('nome ilike ? or sigla ilike ?', "%#{term}%","%#{term}%").order(:nome).all
    orgaos = Orgao.where('nome ilike ? or sigla ilike ?', "%#{term}%","%#{term}%").order(:nome).all
    setoriais = orgaos+departamentos
    render :json => setoriais.map { |setorial| {:id => setorial.id,:type=>setorial.class.name, :label => setorial.nome, :value => setorial.nome} }
  end

  def autocomplete_escola_nome
    term = params[:term]
    escolas = Escola.where('nome ilike ? or codigo ilike ?', "%#{term}%","%#{term}%").order(:nome).all
    render :json => escolas.map { |escola| {:id => escola.id,:type=>"Escola", :label => "#{escola.nome} - #{escola.municipio.nome} - #{escola.rede}", :value => escola.nome} }
  end

  def index
    @lotacaos = Lotacao.all
    @lotacao = Lotacao.new
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @lotacoes_abertas = @funcionario.lotacoes.em_aberto.where('funcionario_id=?',@funcionario.id)
    @lotacoes = @funcionario.lotacoes.order("data_lotacao desc")
    @processos = @funcionario.processos.order("created_at ASC, processo ASC")
    @url = pessoa_funcionario_lotacoes_path(@pessoa,@funcionario)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lotacaos }
    end
  end

  def destinos
    respond_to do |format|
      format.json{
        @escolas = Escola.where('nome LIKE ?', "%#{params[:query]}%").limit(20).order('nome')
        render :json => { :query => params[:query], :suggestions => escolas.map(&:nome), :data => escolas.map(&:id) }
      }
    end
  end

  def gerar_relatorio
    @responsavel = User.usuario_atual
    render :layout=>"facebox"
  end

  def gerar_arquivo
    @inicio = Date.civil(params[:relatorio]["inicio(1i)"].to_i,
     params[:relatorio]["inicio(2i)"].to_i,
     params[:relatorio]["inicio(3i)"].to_i)
    @fim = Date.civil(params[:relatorio]["fim(1i)"].to_i,
      params[:relatorio]["fim(2i)"].to_i,
      params[:relatorio]["fim(3i)"].to_i)
    relatorio(@inicio.to_date,@fim.to_date)
    render :layout=>false
  end

  def regencia
    if params[:tipo_lotacao].nil?
      render :partial=>"prolabore"
    else
      render :partial=>"regular"
    end
  end

  def complementar_esp
    if params[:esp]=='ESPECIAL' or params[:esp]=='SUMARIA ESPECIAL'
      render :partial=>"complementar_desabilitado"
    else
      render :partial=>"complementar_habilitado"
    end
  end

  def complementar
    if params[:complemento]=='1'
      render :partial=>"prolabore"
    else
      render :partial=>"regular"
    end
  end

  def lotacao_especial
    if params[:tp_lotacao]=='ESPECIAL' or params[:tp_lotacao]=='SUMARIA ESPECIAL'
      render :partial=>"esfera"
    else
      render :partial=>"orgao_regular"
    end
  end

  def destino
    if params[:esfera].size>0
      @esfera = Esfera.find(params[:esfera])
      @orgaos_esfera = @esfera.orgaos.order(:nome).collect{|o|[o.nome.upcase,o.id]}
      render :partial=>"destino"
    else
      render :partial=>"destino_nulo"
    end
  end



  def tipo_destino
    if params[:orgao].size>0
      @orgao = Orgao.find(params[:orgao])
      @esfera = Esfera.find(@orgao.esfera_id)
      @tipos_destino = TipoDestino.all.collect{|e|[e.nome,e.id]}
      if @orgao.departamentos.size>0
        render :partial=>"tipo_destino"
      else
        render :partial=>"destino_nulo"
      end
    else
      render :partial=>"destino_nulo"
    end
  end

  def escolas_destino
    if params[:tipo_destino].size>0
      @orgao = Orgao.find(params[:orgao_id])
      @tipo = TipoDestino.find(params[:tipo_destino])
      @escolas_lot_especial = @orgao.escolas.order(:nome).collect{|e|[e.nome,e.id]}
      @departamentos = @orgao.departamentos.order(:nome).collect{|e|[e.nome,e.id]}
      case @tipo.nome
      when 'Escola' then
        if @escolas_lot_especial.size==0
          render :partial=>"destino_nulo"
        else
          render :partial=>"escolas"
        end
      when 'Departamento' then
        render :partial=>"departamentos"
      end

    else
      render :partial=>"destino_nulo"
    end
  end



  # GET /lotacaos/1
  # GET /lotacaos/1.xml
  def show
    @lotacao = Lotacao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lotacao }
    end
  end


  def especificar_lotacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = Lotacao.find(params[:lotacao_id])
    @escola_lotacao = @lotacao.destino
    @especificacao= EspecificarLotacao.new
    render :layout=>"facebox"

  end

  def auto_complete_for_escola_nome
    @escolas = Escola.find(:all,
     :conditions => [ 'LOWER(nome) iLIKE ?',
      '%' + params[:escola][:nome].downcase + '%' ])
    render :partial => "busca_escolas"

  end

  def auto_complete_for_departamento_nome
    @departamentos = Departamento.find(:all,
     :conditions => [ 'LOWER(nome) iLIKE ?',
      '%' + params[:departamento][:nome].downcase + '%' ])
    render :partial => "busca_departamentos"

  end

  def disciplinas_especificacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = Lotacao.find(params[:lotacao_id])
    @escola_lotacao = @lotacao.destino
    if !params[:turma].blank?
      @turma = Turma.find params[:turma]
      @serie = @turma.serie
      #@disciplinas = @serie.disciplinas.where("disciplinas.id in (?)",@funcionario.ids_disciplinas).uniq.collect{|d|[d.nome,d.id]}
      @disciplinas = @serie.disciplinas.find(:all,:order=>'nome asc').uniq.collect{|d|[d.nome,d.id]}
      render :partial=>"disciplinas"
    else
      render :nothing=>true
    end
  end

  def tipo_especificacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = @funcionario.lotacoes.find(params[:lotacao_id])
    @escola = @lotacao.destino
    @ambiente = @escola.ambientes.find_by_nome("Sala de Aula")
    @turmas = Turma.find(:all,:joins=>[:serie],:conditions=>["ambiente_id= ? and escola_id = ?",@ambiente.id,@escola.id],:order => 'turno,nome')
    @tipo = params[:tipo]
    @ambientes = @escola.ambientes.find(:all,:conditions=>["nome not like ?",@ambiente.nome],:order=>"nome asc").collect{|a|[a.nome,a.id]}
    render :partial=>"tipo_especificacao"
  end

  def salvar_confirmacao
    @usuario= current_user
    @funcionario = Funcionario.find(params[:funcionario_id])
    @confirma = params[:confirmacao][:codigo_barra]
    @lotacao = Lotacao.em_aberto.find(params[:lotacao_id])
    @codigo = params[:confirmacao][:codigo_barra]
    if @codigo==@lotacao.codigo_barra
      @lotacao.confirma_lotacao
      @lotacao.confirmar
      @lotacao.adicionar_lot_observacoes('confirmacao')
      redirect_to pessoa_funcionario_lotacoes_url(@pessoa,@funcionario), :notice => 'Confirmação de Lotação Efetuada.'
    else
      redirect_to  pessoa_funcionario_lotacoes_url(@pessoa,@funcionario), :alert => 'Confirmação de Lotação não executada, Código de Barras incorreto'
    end

  end

  def salvar_especificacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = @funcionario.pessoa
    @lotacao = Lotacao.find(params[:lotacao_id])
    @tipo=params[:especificar_lotacao][:tipo]
    @escola = @lotacao.destino
    if @tipo!="Sala Ambiente"
      @turma = Turma.find(params[:especificar_lotacao][:turma_id])
      @serie = @turma.serie
      @disciplina = @serie.disciplinas.find(params[:especificar_lotacao][:disciplina_id])
      @curriculo = @turma.matriz.curriculos.da_serie(@serie.id).da_disciplina(@disciplina.id).last
      @ambiente = @escola.ambientes.find_by_nome("Sala de Aula")
    else
      @ambiente = Ambiente.find(params[:especificar_lotacao][:ambiente_id])
    end
    respond_to do |format|
      if @funcionario.especificar_lotacao(@escola,@turma,@disciplina,@curriculo,@lotacao,@tipo,@ambiente)
        format.html { redirect_to("#{escola_path(@lotacao.destino)}#tab-dois",:notice => "O Funcionário foi especificado com sucesso.") }
      else
        format.html { redirect_to("#{escola_path(@lotacao.destino)}#tab-dois", :alert => "A lotação não pode ser especificada.") }
      end
    end

  end


  def salvar_cancelamento
    motivo = params[:cancelar_lotacao][:motivo]
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = @funcionario.pessoa
    @lotacao = Lotacao.em_aberto.find(params[:lotacao_id])
    @lotacao.cancela_lotacao(motivo)
    @lotacao.cancelar
    @lotacao.lot_observacoes.create(:item=>'Cancelado',:descricao=>"Motivo: #{motivo}",:responsavel=>"#{current_user.name}")
    # if params[:cancelar][:cancelar]=="true"
    #   redirect_to lotacoes_convalidar_path, :notice => 'Lotação Cancelada.'
    # elsif params[:cancelar][:cancelar]=="false" or params[:cancelar][:cancelar]==nil or params[:cancelar][:cancelar]==""
    #   redirect_to pessoa_funcionario_lotacoes_path(@pessoa,@funcionario), :notice => 'Lotação Cancelada.'
    # end
    redirect_to pessoa_funcionario_lotacoes_path(@pessoa,@funcionario), :notice => 'Lotação Cancelada.'
  end


  def salvar_devolucao
    @usuario = current_user
    motivo = params[:devolucao][:motivo]
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = @funcionario.pessoa
    # @lotacao = Lotacao.finalizadas.find(params[:lotacao_id])
    @lotacao = Lotacao.find(params[:lotacao_id])
    @lotacao.devolve_funcionario(motivo)
    # tirei esse aqui
    @lotacao.devolver
    # tirei esse aqui
    @lotacao.lot_observacoes.create(:item=>'Devolvido',:descricao=>"Motivo: #{motivo}",:responsavel=>"#{@usuario.name}")
    redirect_to pessoa_funcionario_lotacoes_path(@pessoa,@funcionario), :notice => 'Funcionário Devolvido ao NUPES'
  end

  def salvar_convalidacao
    motivo = params[:motivo]
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = Lotacao.em_aberto.find(params[:lotacao_id])
    redirect_to pessoa_funcionario_lotacoes_path(@pessoa,@funcionario), :notice => 'Funcionário Devolvido ao NUPES'
  end

  def verifica_lotacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @escola = Escola.find(params[:escola_id])
    @lotacao = Lotacao.verifica(@funcionario.id,@escola.id).first
    if @lotacao
      render :partial=>"verifica_lotacao"
    else
      render :partial=>"form"
    end
  end

  def devolver_funcionario
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = Lotacao.finalizada.find(params[:lotacao_id])
    render :layout=>"facebox"
  end

  def confirmar_lotacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = Lotacao.em_aberto.find(params[:lotacao_id])
    render :layout=>"facebox"
  end

  def cancelar_lotacao
    if params[:convalidar]
      @cancelar = params[:convalidar]
    end
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = @funcionario.pessoa
    @lotacao = Lotacao.em_aberto.find(params[:lotacao_id])
    render :layout=>"facebox"
  end

  def convalidar
    @lotacao_aberta = Lotacao.em_aberto.a_convalidar.find :all
    respond_to do |format|
      format.html # index.html.erb
    end
  end


  # GET /lotacaos/new
  # GET /lotacaos/new.xml
  def new
    @lotacao = Lotacao.new
    @lotacao_aberta = Lotacao.em_aberto.last
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lotacao }
    end
  end

  # GET /lotacaos/1/edit
  def edit
    @lotacao = Lotacao.find(params[:id])
  end

  # POST /lotacaos
  # POST /lotacaos.xml
  def create
    @lotacaos = Lotacao.all
    @tipos = [["Escola","REGULAR"],["Setorial","ESPECIAL"]]
    @lotacoes_abertas = @funcionario.lotacoes.em_aberto.where('funcionario_id=?',@funcionario.id)
    @lotacoes = @funcionario.lotacoes.order("data_lotacao desc")
    @processos = @funcionario.processos.order("created_at ASC, processo ASC")
    @url = pessoa_funcionario_lotacoes_path(@pessoa,@funcionario)
    @lotacao = Lotacao.new(params[:lotacao])

    respond_to do |format|
      if @lotacao.save
        @lotacao.encaminhar!
        # @lotacao.lot_observacoes('encaminhamento')
        if @funcionario.categoria_contrato? and @funcionario.contrato and @funcionario.contrato.lotacao_id.blank?
          @funcionario.contrato.update_attributes(:lotacao_id=>@lotacao.id)
        end

        puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAé aqui"
        format.html { redirect_to(pessoa_funcionario_lotacoes_path(@pessoa,@funcionario), :notice => "O Funcionário foi lotado com sucesso.
          Destino: #{@lotacao.destino.nome}") }
        format.xml  { render :xml => @lotacao, :status => :created, :location => @lotacao }
      else
        format.html { render :action => "index",:danger=>"Lotação não criada" }
        format.xml  { render :xml => @lotacao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lotacaos/1
  # PUT /lotacaos/1.xml
  def update
    @lotacao = Lotacao.find(params[:id])
    respond_to do |format|
      if @lotacao.update_attributes(params[:lotacao])
        if @lotacao.quick==true
          format.html { redirect_to(pessoas_url, :notice => 'Lotação Especificada com sucesso.') }
          format.xml  { head :ok }
        else
          format.html { redirect_to(:back, :notice => 'Processo de lotação atualizado com sucesso.') }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lotacao.errors, :status => :unprocessable_entity }
      end
    end
  end



  def fator_lotacao
    @funcionario = Funcionario.find(params[:funcionario_id])
    @turma = Turma.find(params[:turma_id])
    @escola = @turma.escola
    @serie = @turma.serie
    @lotacao = @funcionario.lotacoes.find(params[:lotacao_id])
    if !params[:disciplina_id].blank?
      @disciplina = @serie.disciplinas.find(params[:disciplina_id])
      @curriculo = @turma.matriz.curriculos.da_serie(@serie.id).da_disciplina(@disciplina.id).last
      @fator = @disciplina.pode_especificar?(@turma)
      @fator_n = @disciplina.fator(@turma)
      if @fator==true and @fator_n>0
        if (@funcionario.rsd - @fator_n) >=0
          @motivo="Regência Semanal compatível"
          render :partial=>"fator_lotacao"
        else
          @motivo="Regência Semanal incompatível"
          render :partial=>"nao_pode_especificar"
        end
      else
        @motivo="Não há carencia para a disciplina nesta turma."
        render :partial=>"nao_pode_especificar"
      end
    else
      render :nothing=>true
    end
  end



  def fator_lotacao_fisico
    @funcionario = Funcionario.find(params[:funcionario_id])
    @lotacao = Lotacao.find(params[:lotacao_id])
    @escola = @lotacao.destino
    if !params[:ambiente].blank?
      @ambiente = Ambiente.find(params[:ambiente])
      if @ambiente.fator_ambiente(@funcionario)[0]==true
        @motivo="Regência Semanal Compatível"
        render :partial=>"fator_lotacao_fisico"
      elsif @ambiente.fator_ambiente(@funcionario)[0]==false
        @motivo="Não há carência de professores neste ambiente."
        render :partial=>"nao_pode_especificar_fisico"
      else
        @motivo="Regência semanal incompatível."
        render :partial=>"nao_pode_especificar_fisico"
      end
    else
      render :nothing=>true
    end
  end

  def especificacao_massiva
    @lotacao = Lotacao.find(params[:lotacao_id])
    @funcionario = @lotacao.funcionario
    @pessoa = @funcionario.pessoa
    @escola = @lotacao.destino
    #@disciplinas = Disciplina.find(:all,:conditions=>["id in (?)",@funcionario.ids_disciplinas]).collect{|d|[d.nome,d.id]}
    @disciplinas = @escola.disciplinas.collect{|d|[d.nome,d.id]}
    render :layout=>"facebox"
  end

  def turmas
    @lotacao = Lotacao.find(params[:especificacao][:lotacao_id])
    @funcionario = @lotacao.funcionario
    @pessoa = @funcionario.pessoa
    @escola = @lotacao.destino
    if !params[:especificacao][:disciplina_id].blank?
      @disciplina = Disciplina.find(params[:especificacao][:disciplina_id])
    end
    if !params[:especificacao][:turno].blank?
      @turno = params[:especificacao][:turno]
    end

    if @disciplina and @turno
      @turmas = @escola.turmas.da_escola(@escola).find(:all,:joins=>:curriculos,:conditions=>["turno = ? and curriculos.disciplina_id = ?",@turno,@disciplina.id]).uniq
      render :partial=>"turmas"
    else
      render :nothing=>true
    end
  end

  def salvar_especificacoes
    @lotacao = Lotacao.find(params[:especificacao][:lotacao_id])
    @funcionario = @lotacao.funcionario
    @pessoa = @funcionario.pessoa
    @escola = @lotacao.destino
    turmas = params[:turmas]
    @turmas = Turma.find(:all,:conditions=>["id in (?)",turmas])
    @ambiente = @escola.ambientes.find_by_nome("Sala de Aula")
    @tipo = @ambiente.nome
    @disciplina = Disciplina.find(params[:especificacao][:disciplina_id])
    falhas = []
    sucessos = []
    soma_fator = 0
    @turmas.each do |turma|
      curriculo = turma.matriz.curriculos.da_serie(turma.serie.id).da_disciplina(@disciplina.id).last
      fator = @disciplina.pode_especificar?(turma)
      fator_n = @disciplina.fator(turma)
      if fator==true and fator_n>0
        soma_fator+=fator_n
      end
    end
    #if soma_fator<=@funcionario.rsd
    @turmas.each do |turma|
      curriculo = turma.matriz.curriculos.da_serie(turma.serie.id).da_disciplina(@disciplina.id).last
      @funcionario.especificar_lotacao(@escola,turma,@disciplina,curriculo,@lotacao,@tipo,@ambiente)
    end
    notice = (flash[:notice] = "O Funcionário foi especificado com sucesso nas seguintes turmas: #{@turmas.collect{|t|t.nome}.to_sentence}")
    # else
    #   notice = (flash[:alert] = "O Funcionário não foi especificado, pois a RSD do Funcionário (#{@funcionario.rsd}) é menor que a carência total das turmas selecionadas (#{soma_fator}).")
    #   sucesso = false
    # end
    render :update do |page|
      page.reload()
      notice
    end
  end

  # DELETE /lotacaos/1
  # DELETE /lotacaos/1.xml
  def destroy
    @lotacao = Lotacao.find(params[:id])
    @lotacao.destroy

    respond_to do |format|
      format.html { redirect_to(pessoa_funcionario_lotacoes_url) }
      format.xml  { head :ok }
    end
  end

  def apagar_especificacao
    @lotacao = Lotacao.find(params[:lotacao_id])
    @especificacao = @lotacao.especificacoes.find(params[:especificacao_id])
    @especificacao.destroy
    respond_to do |format|
      format.html { redirect_to("#{escola_path(@lotacao.destino)}#tab-tres",:notice => 'Especificação de lotação desfeita com sucesso.') }
      format.xml  { head :ok }
    end
  end



  private

  def relatorio(inicio,fim)
    @lotacoes = Lotacao.atual.find :all,:limit=>10,:conditions=>["data_lotacao BETWEEN (?) and (?)",inicio,fim]
    # relatorio = ODFReport::Report.new("#{Rails.root}/public/relatorios/lotacao.odt") do |r|
    #   r.add_table("FUNCIONARIOS", @lotacoes, :header=>true) do |t|
    #     t.add_column(:nome) {|l| "#{l.funcionario.pessoa.nome}"}
    #     t.add_column(:mat) {|l| "#{l.funcionario.matricula}"}
    #     t.add_column(:car) {|l| "#{cargo_resumido(l.funcionario)}"}
    #     t.add_column(:cpf) {|l| "#{Cpf.new(l.funcionario.pessoa.cpf)}"}
    #     t.add_column(:cat) {|l| "#{l.funcionario.categoria.nome}"}
    #     t.add_column(:proc) {|l| "#{l.processos.first.processo}"}
    #     t.add_column(:user) {|l| "#{l.usuario}"}
    #     t.add_column(:lotacao) {|l| "#{dest(l)}"}
    #   end
    # end
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="report.xls"'
    headers['Cache-Control'] = ''
    #send_data(@lotacoes.to_xls, :content_type=>'application/vnd.ms-excel', :filename=> "Relatório de lotações de #{inicio.to_s_br} à #{fim.to_s_br}.xls")
  end

  def funcionario
    @funcionario = Funcionario.find_by_slug(params[:funcionario_id])||Funcionario.find(params[:funcionario_id])
    @pessoa = Pessoa.find_by_slug(params[:pessoa_id])
    @escolas = Escola.all.collect{|p| [p.nome,p.id]}
  end


end
