# -*- encoding : utf-8 -*-
class QuadrosController < ApplicationController
  load_and_authorize_resource
  # GET /quadros
  # GET /quadros.xml

  before_filter :dados_essenciais
  def index
    @search = Quadro.scoped_search(params[:search])
    @quadros = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quadros }
    end
  end

  # GET /quadros/1
  # GET /quadros/1.xml
  def show
    @quadro = Quadro.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @quadro }
    end
  end

  # GET /quadros/new
  # GET /quadros/new.xml
  def new
    @quadro = Quadro.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @quadro }
    end
  end

  # GET /quadros/1/edit
  def edit
    @quadro = Quadro.find(params[:id])
  end

  # POST /quadros
  # POST /quadros.xml
  def create
    @quadro = Quadro.new(params[:quadro])

    respond_to do |format|
      if @quadro.save
        format.html { redirect_to(@quadro, :notice => 'Quadro cadastrado com sucesso.') }
        format.xml  { render :xml => @quadro, :status => :created, :location => @quadro }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @quadro.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /quadros/1
  # PUT /quadros/1.xml
  def update
    @quadro = Quadro.find(params[:id])

    respond_to do |format|
      if @quadro.update_attributes(params[:quadro])
        format.html { redirect_to(@quadro, :notice => 'Quadro atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quadro.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /quadros/1
  # DELETE /quadros/1.xml
  def destroy
    @quadro = Quadro.find(params[:id])
    @quadro.destroy

    respond_to do |format|
      format.html { redirect_to(quadros_url) }
      format.xml  { head :ok }
    end
  end
end
