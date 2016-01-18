# -*- encoding : utf-8 -*-
class ManutencoesController < ApplicationController
  load_and_authorize_resource
  # GET /manutencoes
  # GET /manutencoes.xml
  def index
    #@search = Manutencao.scoped_search(params[:search])
    @manutencoes = Manutencao.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manutencoes }
    end
  end

  # GET /manutencoes/1
  # GET /manutencoes/1.xml
  def show
    @manutencao = Manutencao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @manutencao }
    end
  end

  # GET /manutencoes/new
  # GET /manutencoes/new.xml
  def em_manutencao
    @manutencao = Manutencao.new
    render :partial=>"em_manutencao"

  end

  # GET /manutencoes/1/edit
  def edit
    @manutencao = Manutencao.find(params[:id])
  end

  # POST /manutencoes
  # POST /manutencoes.xml
  def create
    @manutencao = Manutencao.new(params[:manutencao])

    respond_to do |format|
      if @manutencao.save
        @manutencao.colocar_em_manutencao
        format.html { redirect_to(@manutencao, :notice => 'Manutencao cadastrado com sucesso.') }
        format.xml  { render :xml => @manutencao, :status => :created, :location => @manutencao }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @manutencao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manutencoes/1
  # PUT /manutencoes/1.xml
  def update
    @manutencao = Manutencao.find(params[:id])

    respond_to do |format|
      if @manutencao.update_attributes(params[:manutencao])
        format.html { redirect_to(@manutencao, :notice => 'Manutencao atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manutencao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manutencoes/1
  # DELETE /manutencoes/1.xml
  def destroy
    @manutencao = Manutencao.find(params[:id])
    @manutencao.destroy

    respond_to do |format|
      format.html { redirect_to(manutencoes_url) }
      format.xml  { head :ok }
    end
  end
end
