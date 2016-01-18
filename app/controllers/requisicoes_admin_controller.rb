# -*- encoding : utf-8 -*-
class RequisicoesAdminController < ApplicationController
  before_filter :dados_essenciais
  load_and_authorize_resource :class=>"Requisicao"
  # GET /requisicoes
  # GET /requisicoes.xml
  layout 'requisicoes_admin'

  def transicionar
    @requisicao = Requisicao.find(params[:requisicao_id])
    @requisicao.status = params[:next_status]
    @requisicao.save
    redirect_to requisicoes_admin_path(@requisicao)
  end

  def index
    @q = Requisicao.ransack(params[:q])
    @requisicoes = @q.result(distinct: true).accessible_by(current_ability).order("created_at asc").paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requisicoes }
    end
  end

  # GET /requisicoes/1
  # GET /requisicoes/1.xml
  def show
    @requisicao = Requisicao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @requisicao }
    end
  end

  # GET /requisicoes/new
  # GET /requisicoes/new.xml
  def new
    @periodos = Periodo.all.collect{|p|["#{t p.inicio.strftime("%B")} - #{t p.fim.strftime("%B")}",p.id]}
    @requisicao = Requisicao.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @requisicao }
    end
  end


  # GET /requisicoes/1/edit
  def edit
    @requisicao = Requisicao.find(params[:id])
    @periodos = Periodo.all.collect{|p|["#{t p.inicio.strftime("%B")} - #{t p.fim.strftime("%B")}",p.id]}
  end

  # POST /requisicoes
  # POST /requisicoes.xml
  def create
    @requisicao = Requisicao.new(params[:requisicao])
    @periodos = Periodo.all.collect{|p|["#{t p.inicio.strftime("%B")} - #{t p.fim.strftime("%B")}",p.id]}
    respond_to do |format|
      if @requisicao.save
        format.html { redirect_to(@requisicao, :notice => 'Requisicao cadastrado com sucesso.') }
        format.xml  { render :xml => @requisicao, :status => :created, :location => @requisicao }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @requisicao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /requisicoes/1
  # PUT /requisicoes/1.xml
  def update
    @requisicao = Requisicao.find(params[:id])
    @periodos = Periodo.all.collect{|p|["#{t p.inicio.strftime("%B")} - #{t p.fim.strftime("%B")}",p.id]}
    respond_to do |format|
      if @requisicao.update_attributes(params[:requisicao])
        format.html { redirect_to(@requisicao, :notice => 'Requisicao atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @requisicao.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /requisicoes/1
  # DELETE /requisicoes/1.xml
  def destroy
    @requisicao = Requisicao.find(params[:id])
    @requisicao.destroy

    respond_to do |format|
      format.html { redirect_to(requisicoes_url) }
      format.xml  { head :ok }
    end
  end
end
