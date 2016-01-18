# -*- encoding : utf-8 -*-
class Folha::FolhasController < ApplicationController
  load_and_authorize_resource :class=> Folha::Folha
  # GET /folha/folhas
  # GET /folha/folhas.xml
  before_filter :criar_atualizar,:except=>[:show,:create,:update,:destroy,:index]
  before_filter :fonte_recursos
  def index
    @search = Folha::Folha.scoped_search(params[:search])
    @folha_folhas = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folha_folhas }
    end
  end

  # GET /folha/folhas/1
  # GET /folha/folhas/1.xml
  def show
    @folha_folha = Folha::Folha.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folha_folha }
    end
  end

  #impressão de Financeiro a Partir da Folha e alguns parametros
  def imprimir_financeiros
    @folha = Folha::Folha.find(params[:folha_id])
    @financeiros = @folha.financeiros.all
    render :layout=>nil
  end
  # GET /folha/folhas/new
  # GET /folha/folhas/new.xml
  def new
    @folha_folha = Folha::Folha.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folha_folha }
    end
  end

  # GET /folha/folhas/1/edit
  def edit
    @folha_folha = Folha::Folha.find(params[:id])
  end

  # POST /folha/folhas
  # POST /folha/folhas.xml
  def create
    @folha_folha = Folha::Folha.new(params[:folha_folha])

    respond_to do |format|
      if @folha_folha.save
        format.html { redirect_to(@folha_folha, :notice => 'Folha cadastrado com sucesso.') }
        format.xml  { render :xml => @folha_folha, :status => :created, :location => @folha_folha }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folha_folha.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /folha/folhas/1
  # PUT /folha/folhas/1.xml
  def update
    @folha_folha = Folha::Folha.find(params[:id])

    respond_to do |format|
      if @folha_folha.update_attributes(params[:folha_folha])
        format.html { redirect_to(@folha_folha, :notice => 'Folha atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @folha_folha.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /folha/folhas/1
  # DELETE /folha/folhas/1.xml
  def destroy
    @folha_folha = Folha::Folha.find(params[:id])
    @folha_folha.destroy

    respond_to do |format|
      format.html { redirect_to(folha_folhas_url) }
      format.xml  { head :ok }
    end
  end


  private
  def criar_atualizar
    @competencias = Folha::Competencia.order(:nome).collect{|p|[p.nome,p.id]}
  end

  def fonte_recursos
    @recursos = Folha::FonteRecurso.all.collect { |r|[r.nome,r.id]  }
  end
end
