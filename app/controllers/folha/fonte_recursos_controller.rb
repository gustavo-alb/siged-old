# -*- encoding : utf-8 -*-
class Folha::FonteRecursosController < ApplicationController
  load_and_authorize_resource :class=> Folha::FonteRecurso
  # GET /folha/fonte_recursos
  # GET /folha/fonte_recursos.xml
  before_filter :esferas
  def index

    @folha_fonte_recursos = Folha::FonteRecurso.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folha_fonte_recursos }
    end
  end

  # GET /folha/fonte_recursos/1
  # GET /folha/fonte_recursos/1.xml
  def show
    @folha_fonte_recurso = Folha::FonteRecurso.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folha_fonte_recurso }
    end
  end

  # GET /folha/fonte_recursos/new
  # GET /folha/fonte_recursos/new.xml
  def new
    @folha_fonte_recurso = Folha::FonteRecurso.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folha_fonte_recurso }
    end
  end

  # GET /folha/fonte_recursos/1/edit
  def edit
    @folha_fonte_recurso = Folha::FonteRecurso.find(params[:id])
  end

  # POST /folha/fonte_recursos
  # POST /folha/fonte_recursos.xml
  def create
    @folha_fonte_recurso = Folha::FonteRecurso.new(params[:folha_fonte_recurso])

    respond_to do |format|
      if @folha_fonte_recurso.save
        format.html { redirect_to(@folha_fonte_recurso, :notice => 'Fonte recurso cadastrado com sucesso.') }
        format.xml  { render :xml => @folha_fonte_recurso, :status => :created, :location => @folha_fonte_recurso }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folha_fonte_recurso.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /folha/fonte_recursos/1
  # PUT /folha/fonte_recursos/1.xml
  def update
    @folha_fonte_recurso = Folha::FonteRecurso.find(params[:id])

    respond_to do |format|
      if @folha_fonte_recurso.update_attributes(params[:folha_fonte_recurso])
        format.html { redirect_to(@folha_fonte_recurso, :notice => 'Fonte recurso atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @folha_fonte_recurso.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /folha/fonte_recursos/1
  # DELETE /folha/fonte_recursos/1.xml
  def destroy
    @folha_fonte_recurso = Folha::FonteRecurso.find(params[:id])
    @folha_fonte_recurso.destroy

    respond_to do |format|
      format.html { redirect_to(folha_fonte_recursos_url) }
      format.xml  { head :ok }
    end
  end
  private
  def esferas
    @esferas = Esfera.all.collect { |e| [e.nome,e.id]  }
  end
end
