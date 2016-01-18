# -*- encoding : utf-8 -*-
class Arquivo::DocumentosController < ApplicationController
  # GET /arquivo/documentos
  # GET /arquivo/documentos.xml
  def index
    @search = Arquivo::Documento.scoped_search(params[:search])
    @arquivo_documentos = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @arquivo_documentos }
    end
  end

  # GET /arquivo/documentos/1
  # GET /arquivo/documentos/1.xml
  def show
    @arquivo_documento = Arquivo::Documento.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @arquivo_documento }
    end
  end

  # GET /arquivo/documentos/new
  # GET /arquivo/documentos/new.xml
  def new
    @arquivo_documento = Arquivo::Documento.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @arquivo_documento }
    end
  end

  # GET /arquivo/documentos/1/edit
  def edit
    @arquivo_documento = Arquivo::Documento.find(params[:id])
  end

  # POST /arquivo/documentos
  # POST /arquivo/documentos.xml
  def create
    @arquivo_documento = Arquivo::Documento.new(params[:arquivo_documento])

    respond_to do |format|
      if @arquivo_documento.save
        format.html { redirect_to(@arquivo_documento, :notice => 'Documento cadastrado com sucesso.') }
        format.xml  { render :xml => @arquivo_documento, :status => :created, :location => @arquivo_documento }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @arquivo_documento.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /arquivo/documentos/1
  # PUT /arquivo/documentos/1.xml
  def update
    @arquivo_documento = Arquivo::Documento.find(params[:id])

    respond_to do |format|
      if @arquivo_documento.update_attributes(params[:arquivo_documento])
        format.html { redirect_to(@arquivo_documento, :notice => 'Documento atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @arquivo_documento.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /arquivo/documentos/1
  # DELETE /arquivo/documentos/1.xml
  def destroy
    @arquivo_documento = Arquivo::Documento.find(params[:id])
    @arquivo_documento.destroy

    respond_to do |format|
      format.html { redirect_to(arquivo_documentos_url) }
      format.xml  { head :ok }
    end
  end
end
