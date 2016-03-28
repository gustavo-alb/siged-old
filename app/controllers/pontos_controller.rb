# -*- encoding : utf-8 -*-
class PontosController < ApplicationController
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  helper :all
  self.view_paths = "app/views"
  load_and_authorize_resource
  # GET /pontos
  # GET /pontos.xml
  before_filter :ponto_lotacao,:except=>[:funcionarios,:salvar_pontos,:gerar_pontos]
  def index
    @pontos = Ponto.da_lotacao(@lotacao.id).paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pontos }
    end
  end

  # GET /pontos/1
  # GET /pontos/1.xml
  def show
    @ponto = Ponto.find(params[:id])
    @range_dias = @ponto.data.at_beginning_of_month..@ponto.data.at_end_of_month

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ponto }
    end
  end

  # GET /pontos/new
  # GET /pontos/new.xml
  def new
    @ponto = Ponto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ponto }
    end
  end

  def gerar_arquivo
    @ponto = Ponto.find(params[:ponto_id])
    send_data @ponto.arquivo_ponto.file.read,:filename=>"Ponto de #{@pessoa.nome} - #{@funcionario.matricula}.pdf", :type => "application/pdf", :disposition => "attachment"
  end


  # GET /pontos/1/edit
  def edit
    @ponto = Ponto.find(params[:id])
  end

  # POST /pontos
  # POST /pontos.xml
  def create
    @ponto = Ponto.new(params[:ponto])
    @orgao = @lotacao.orgao
    @ponto.usuario = current_user
    respond_to do |format|
      if @ponto.save
        format.html { redirect_to(pessoa_funcionario_lotacao_pontos_path(@pessoa,@funcionario,@lotacao), :notice => 'Ponto cadastrado com sucesso.') }
        format.xml  { render :xml => @ponto, :status => :created, :location => @ponto }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ponto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pontos/1
  # PUT /pontos/1.xml
  def update
    @ponto = Ponto.find(params[:id])

    respond_to do |format|
      if @ponto.update_attributes(params[:ponto])
        format.html { redirect_to(orgao_departamento_pontos_path(@orgao,@departamento,:funcionario_id=>@funcionario.id), :notice => 'Ponto atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ponto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pontos/1
  # DELETE /pontos/1.xml
  def destroy
    @ponto = Ponto.find(params[:id])
    if @ponto.destroy
      respond_to do |format|
        format.html { redirect_to(:back,:alert=>"Ponto apagado com sucesso") }
        format.xml  { head :ok }
      end
    end
  end

  def gerar_pontos
    @obj = params[:objeto_id]
    @tipo = params[:tipo]
    case @tipo
    when "orgao"
      @objeto = Orgao.find(@obj)
      @obj_tipo = "Orgão"
    when "departamento"
      @objeto = Departamento.find(@obj)
      @obj_tipo = "Setorial"
    when "escola"
      @objeto = Escola.find(@obj)
      @obj_tipo = "Escola"
    end
    render :layout=>'facebox'
  end

  def salvar_pontos
    data = Date.civil(params[:ponto]["data(1i)"].to_i, params[:ponto]["data(2i)"].to_i, params[:ponto]["data(3i)"].to_i)
    @obj = params[:objeto_id]
    @tipo = params[:tipo]
    case @tipo
    when "orgao"
      @objeto = Orgao.find(@obj)
      @obj_tipo = "Orgão"
    when "departamento"
      @objeto = Departamento.find(@obj)
      @obj_tipo = "Setorial"
    when "escola"
      @objeto = Escola.find(@obj)
      @obj_tipo = "Escola"
    end
    @data = data
    @devolvidos = @objeto.lotacoes.where("lotacaos.finalizada = ? and ? BETWEEN lotacaos.data_lotacao and lotacaos.data_devolucao",true,@data)
    @atuais = @objeto.lotacoes.where("lotacaos.finalizada = ? and lotacaos.data_lotacao <= ? and lotacaos.data_devolucao is null",true,@data.end_of_month)
    @lotacoes = @devolvidos+@atuais.sort_by{|l|l.pessoa.nome}
    @pdf = CombinePDF.new
    @lotacoes.each do |l|
      ponto = l.pontos.find_by_data(data)||l.funcionario.pontos.create(:data=>data,:funcionario_id=>l.funcionario.id,:lotacao_id=>l.id,:usuario=>current_user)
      @pdf << CombinePDF.parse(ponto.arquivo_ponto.file.read)
    end
    send_data @pdf.to_pdf,:filename=>"Ponto Mensal - #{@objeto.sigla} - #{ I18n.l(data,:format=>"%B de %Y").upcase}.pdf",:type=> 'application/pdf'
  end

  def funcionarios
    @meses = [["Janeiro", 1], ["Fevereiro", 2], ["Março", 3], ["Abril", 4], ["Maio", 5], ["Junho", 6], ["Julho", 7], ["Agosto", 8], ["Setembro", 9], ["Outubro", 10], ["Novembro", 11], ["Dezembro", 12]]
    @obj = params[:objeto_id]||params[:ponto][:objeto_id]
    @tipo = params[:tipo]||params[:ponto][:tipo]
    case @tipo
    when "orgao"
      @objeto = Orgao.find(@obj)
      @obj_tipo = "Orgão"
    when "departamento"
      @objeto = Departamento.find(@obj)
      @obj_tipo = "Setorial"
    when "escola"
      @objeto = Escola.find(@obj)
      @obj_tipo = "Escola"
    end
    data = Date.parse("01/#{params[:ponto][:mes]}/#{params[:ponto][:ano]}") if params[:ponto]
    @data = data||Date.today
    #@data = params[:data] || Date.today
    @devolvidos = @objeto.funcionarios.joins(:pessoa,:lotacoes).where("lotacaos.finalizada = ? and ? BETWEEN lotacaos.data_lotacao and lotacaos.data_devolucao",true,@data)

    @atuais = @objeto.funcionarios.joins(:pessoa,:lotacoes).where("lotacaos.finalizada = ? and lotacaos.data_lotacao <= ? and lotacaos.data_devolucao is null",true,@data.end_of_month)
    @funcionarios = (@devolvidos+@atuais).uniq.sort_by{|f|f.pessoa.nome}.paginate :page => params[:page], :per_page => 8
    @encaminhados = @objeto.funcionarios.joins(:lotacoes).where("lotacaos.finalizada = ? and lotacaos.ativo = ?",false,true).uniq.paginate :page => params[:page], :per_page => 8
    @aba = params[:aba]
    respond_to do |format|
      format.html # index.html.erb
      format.js {
        case @aba
        when "encaminhados"
          render :encaminhados
        when "funcionarios"
          render :funcionarios
        end
      }
    end
  end


  private

  def ponto_lotacao
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.find(params[:funcionario_id])
    @lotacao = @funcionario.lotacoes.atual.find(params[:lotacao_id])
  end
end
