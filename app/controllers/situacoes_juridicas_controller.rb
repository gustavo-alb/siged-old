# -*- encoding : utf-8 -*-
class SituacoesJuridicasController < ApplicationController
  load_and_authorize_resource
  # GET /situacoes_juridicas
  # GET /situacoes_juridicas.xml
  before_filter :eventos_vencimento
  def index
    @search = SituacoesJuridica.scoped_search(params[:search])
    @situacoes_juridicas = @search.order(:nome).paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @situacoes_juridicas }
    end
  end

  # GET /situacoes_juridicas/1
  # GET /situacoes_juridicas/1.xml
  def show
    @situacoes_juridica = SituacoesJuridica.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @situacoes_juridica }
    end
  end

  # GET /situacoes_juridicas/new
  # GET /situacoes_juridicas/new.xml
  def new
    @situacoes_juridica = SituacoesJuridica.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @situacoes_juridica }
    end
  end

  # GET /situacoes_juridicas/1/edit
  def edit
    @situacoes_juridica = SituacoesJuridica.find(params[:id])
  end

  # POST /situacoes_juridicas
  # POST /situacoes_juridicas.xml
  def create
    @situacoes_juridica = SituacoesJuridica.new(params[:situacoes_juridica])

    respond_to do |format|
      if @situacoes_juridica.save
        format.html { redirect_to(@situacoes_juridica, :notice => 'Situação jurídica cadastrada com sucesso.') }
        format.xml  { render :xml => @situacoes_juridica, :status => :created, :location => @situacoes_juridica }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @situacoes_juridica.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /situacoes_juridicas/1
  # PUT /situacoes_juridicas/1.xml
  def update
    @situacoes_juridica = SituacoesJuridica.find(params[:id])

    respond_to do |format|
      if @situacoes_juridica.update_attributes(params[:situacoes_juridica])
        format.html { redirect_to(@situacoes_juridica, :notice => 'Situação jurídica atualizada com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @situacoes_juridica.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /situacoes_juridicas/1
  # DELETE /situacoes_juridicas/1.xml
  def destroy
    @situacoes_juridica = SituacoesJuridica.find(params[:id])
    @situacoes_juridica.destroy

    respond_to do |format|
      format.html { redirect_to(situacoes_juridicas_url) }
      format.xml  { head :ok }
    end
  end
  private

  def eventos_vencimento
    @eventos_vencimentos = Folha::Evento.where("tipo=?",'V').order(:nome).collect{|p|["#{p.nome} - #{p.codigo}",p.id]}

  end
end
