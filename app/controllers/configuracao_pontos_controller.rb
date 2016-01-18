# -*- encoding : utf-8 -*-
class ConfiguracaoPontosController < ApplicationController
  load_and_authorize_resource
  # GET /configuracao_pontos
  # GET /configuracao_pontos.xml
  def index
    @configuracao_pontos = ConfiguracaoPonto.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @configuracao_pontos }
    end
  end

  # GET /configuracao_pontos/1
  # GET /configuracao_pontos/1.xml
  def show
    @configuracao_ponto = ConfiguracaoPonto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @configuracao_ponto }
    end
  end

  # GET /configuracao_pontos/new
  # GET /configuracao_pontos/new.xml
  def new
    @configuracao_ponto = ConfiguracaoPonto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @configuracao_ponto }
    end
  end

  # GET /configuracao_pontos/1/edit
  def edit
    @configuracao_ponto = ConfiguracaoPonto.find(params[:id])
  end

  # POST /configuracao_pontos
  # POST /configuracao_pontos.xml
  def create
    @configuracao_ponto = ConfiguracaoPonto.new(params[:configuracao_ponto])

    respond_to do |format|
      if @configuracao_ponto.save
        format.html { redirect_to(@configuracao_ponto, :notice => 'Configuracao ponto cadastrado com sucesso.') }
        format.xml  { render :xml => @configuracao_ponto, :status => :created, :location => @configuracao_ponto }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @configuracao_ponto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /configuracao_pontos/1
  # PUT /configuracao_pontos/1.xml
  def update
    @configuracao_ponto = ConfiguracaoPonto.find(params[:id])

    respond_to do |format|
      if @configuracao_ponto.update_attributes(params[:configuracao_ponto])
        format.html { redirect_to(@configuracao_ponto, :notice => 'Configuracao ponto atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @configuracao_ponto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /configuracao_pontos/1
  # DELETE /configuracao_pontos/1.xml
  def destroy
    @configuracao_ponto = ConfiguracaoPonto.find(params[:id])
    @configuracao_ponto.destroy

    respond_to do |format|
      format.html { redirect_to(configuracao_pontos_url) }
      format.xml  { head :ok }
    end
  end
end
