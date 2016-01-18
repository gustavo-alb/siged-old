# -*- encoding : utf-8 -*-
class Folha::EventosController < ApplicationController
  load_and_authorize_resource :class=> Folha::Evento
  # GET /folha/eventos
  # GET /folha/eventos.xml
  def index
    @search = Folha::Evento.scoped_search(params[:search])
    @folha_eventos = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folha_eventos }
    end
  end

  # GET /folha/eventos/1
  # GET /folha/eventos/1.xml
  def show
    @folha_evento = Folha::Evento.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folha_evento }
    end
  end

  # GET /folha/eventos/new
  # GET /folha/eventos/new.xml
  def new
    @folha_evento = Folha::Evento.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folha_evento }
    end
  end

  # GET /folha/eventos/1/edit
  def edit
    @folha_evento = Folha::Evento.find(params[:id])
  end

  # POST /folha/eventos
  # POST /folha/eventos.xml
  def create
    @folha_evento = Folha::Evento.new(params[:folha_evento])

    respond_to do |format|
      if @folha_evento.save
        format.html { redirect_to(@folha_evento, :notice => 'Evento cadastrado com sucesso.') }
        format.xml  { render :xml => @folha_evento, :status => :created, :location => @folha_evento }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folha_evento.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /folha/eventos/1
  # PUT /folha/eventos/1.xml
  def update
    @folha_evento = Folha::Evento.find(params[:id])

    respond_to do |format|
      if @folha_evento.update_attributes(params[:folha_evento])
        format.html { redirect_to(@folha_evento, :notice => 'Evento atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @folha_evento.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /folha/eventos/1
  # DELETE /folha/eventos/1.xml
  def destroy
    @folha_evento = Folha::Evento.find(params[:id])
    @folha_evento.destroy

    respond_to do |format|
      format.html { redirect_to(folha_eventos_url) }
      format.xml  { head :ok }
    end
  end
end
