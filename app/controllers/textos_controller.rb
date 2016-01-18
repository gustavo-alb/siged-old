# -*- encoding : utf-8 -*-
class TextosController < ApplicationController
  # GET /textos
  # GET /textos.xml
  load_and_authorize_resource
  before_filter :dados_essenciais,:categoria
  def index
    @search = Texto.scoped_search(params[:search])
    @textos = @search.find(:all,:conditions=>["categoria_id = ?",@categoria.id]).paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @textos }
    end
  end

  # GET /textos/1
  # GET /textos/1.xml
  def show
    @texto = @categoria.textos.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @texto }
    end
  end

  def tipos
    if params[:tipos_texto].size>0
      @tipo = params[:tipos_texto]
      if @tipo=='LOTACAO'
        render :partial=>'blank'
      elsif @tipo=='CATEGORIA'
        render :partial=>'tipos'
      end
    else
      render :partial=>'blank'
    end
  end

  # GET /textos/new
  # GET /textos/new.xml
  def new
    @texto = @categoria.textos.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @texto }
    end
  end

  # GET /textos/1/edit
  def edit
    @texto = @categoria.textos.find(params[:id])
  end

  # POST /textos
  # POST /textos.xml
  def create
    @texto = @categoria.textos.new(params[:texto])

    respond_to do |format|
      if @texto.save
        format.html { redirect_to(categoria_texto_path(@categoria,@texto), :notice => 'Texto cadastrado com sucesso.') }
        format.xml  { render :xml => @texto, :status => :created, :location => @texto }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @texto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /textos/1
  # PUT /textos/1.xml
  def update
    @texto = @categoria.textos.find(params[:id])

    respond_to do |format|
      if @texto.update_attributes(params[:texto])
        format.html { redirect_to(categoria_texto_path(@categoria,@texto), :notice => 'Texto atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @texto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /textos/1
  # DELETE /textos/1.xml
  def destroy
    @texto = @categoria.textos.find(params[:id])
    @texto.destroy

    respond_to do |format|
      format.html { redirect_to(categoria_texto_path(@categoria)) }
      format.xml  { head :ok }
    end
  end
end

private

def categoria
  @categoria = Categoria.find(params[:categoria_id])
end
