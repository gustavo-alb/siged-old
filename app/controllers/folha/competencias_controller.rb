# -*- encoding : utf-8 -*-
class Folha::CompetenciasController < ApplicationController
  load_and_authorize_resource :class=> Folha::Competencia
  # GET /folha/competencias
  # GET /folha/competencias.xml
  def index
    @search = Folha::Competencia.scoped_search(params[:search])
    @folha_competencias = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folha_competencias }
    end
  end

  # GET /folha/competencias/1
  # GET /folha/competencias/1.xml
  def show
    @folha_competencia = Folha::Competencia.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folha_competencia }
    end
  end

  # GET /folha/competencias/new
  # GET /folha/competencias/new.xml
  def new
    @folha_competencia = Folha::Competencia.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folha_competencia }
    end
  end

  # GET /folha/competencias/1/edit
  def edit
    @folha_competencia = Folha::Competencia.find(params[:id])
  end

  # POST /folha/competencias
  # POST /folha/competencias.xml
  def create
    @folha_competencia = Folha::Competencia.new(params[:folha_competencia])

    respond_to do |format|
      if @folha_competencia.save
        format.html { redirect_to(@folha_competencia, :notice => 'Competencia cadastrado com sucesso.') }
        format.xml  { render :xml => @folha_competencia, :status => :created, :location => @folha_competencia }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folha_competencia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /folha/competencias/1
  # PUT /folha/competencias/1.xml
  def update
    @folha_competencia = Folha::Competencia.find(params[:id])

    respond_to do |format|
      if @folha_competencia.update_attributes(params[:folha_competencia])
        format.html { redirect_to(@folha_competencia, :notice => 'Competencia atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @folha_competencia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /folha/competencias/1
  # DELETE /folha/competencias/1.xml
  def destroy
    @folha_competencia = Folha::Competencia.find(params[:id])
    @folha_competencia.destroy

    respond_to do |format|
      format.html { redirect_to(folha_competencias_url) }
      format.xml  { head :ok }
    end
  end
end
