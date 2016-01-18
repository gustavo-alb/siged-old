# -*- encoding : utf-8 -*-
class FormacoesController < ApplicationController
  load_and_authorize_resource
  # GET /formacaos
  # GET /formacaos.xml
  before_filter :pessoa,:only=>[:new,:create,:edit,:update,:destroy,:show,:index]
  before_filter :dados_essenciais
  def index
    @formacoes = Formacao.da_pessoa(@pessoa.id).all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @formacaos }
    end
  end

  def titulos
    if params[:niv].size>0
      @nivel = Nivel.find(params[:niv])
      @titulos = @nivel.titulos.all.collect{|t|[t.nome,t.id]}
      @subtipos = @nivel.subtipos.all.collect{|s|[s.nome,s.id]}
      render :partial=>'titulos'
    else
      render :partial=>'blank'
    end
  end

  # GET /formacaos/1
  # GET /formacaos/1.xml
  def show
    @formacao = Formacao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @formacao }
    end
  end

  # GET /formacaos/new
  # GET /formacaos/new.xml
  def new
    @formacao = Formacao.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @formacao }
    end
  end

  # GET /formacaos/1/edit
  def edit
    @formacao = Formacao.find(params[:id])
    @nivel = @formacao.nivel
  end

  # POST /formacaos
  # POST /formacaos.xml
  def create
    @formacao = Formacao.new(params[:formacao])

    respond_to do |format|
      if @formacao.save
        format.html { redirect_to(pessoa_formacoes_url, :notice => 'Formação cadastrada com sucesso.') }
        format.xml  { render :xml => @formacao, :status => :created, :location => @formacao }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @formacao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /formacaos/1
  # PUT /formacaos/1.xml
  def update
    @formacao = Formacao.find(params[:id])

    respond_to do |format|
      if @formacao.update_attributes(params[:formacao])
        format.html { redirect_to(pessoa_formacoes_url, :notice => 'Formação atualizada com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @formacao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /formacaos/1
  # DELETE /formacaos/1.xml
  def destroy
    @formacao = Formacao.find(params[:id])
    @formacao.destroy

    respond_to do |format|
      format.html { redirect_to(pessoa_formacoes_url) }
      format.xml  { head :ok }
    end
  end
end
private
def pessoa
  @pessoa = Pessoa.find(params[:pessoa_id])
end
