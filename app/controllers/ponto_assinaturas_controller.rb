# -*- encoding : utf-8 -*-
class PontoAssinaturasController < ApplicationController
  load_and_authorize_resource
  # GET /ponto_assinaturas
  # GET /ponto_assinaturas.xml
  before_filter :ponto_assinatura_dados
  def index
    @search = PontoAssinatura.scoped_search(params[:search])
    @ponto_assinaturas = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ponto_assinaturas }
    end
  end

  def assinar_ponto
    @assinatura =@ponto_diario.ponto_assinaturas.do_ano(Time.now.year).do_mes(Time.now.month).do_dia(Time.now.day).first
  end
  # GET /ponto_assinaturas/1
  # GET /ponto_assinaturas/1.xml
  def show
    @ponto_assinatura = PontoAssinatura.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ponto_assinatura }
    end
  end

  # GET /ponto_assinaturas/new
  # GET /ponto_assinaturas/new.xml
  def new
    @ponto_assinatura = PontoAssinatura.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ponto_assinatura }
    end
  end

  # GET /ponto_assinaturas/1/edit
  def edit
    @ponto_assinatura = PontoAssinatura.find(params[:id])
  end

  # POST /ponto_assinaturas
  # POST /ponto_assinaturas.xml
  def create
    @ponto_assinatura = PontoAssinatura.new(params[:ponto_assinatura])

    respond_to do |format|
      if @ponto_assinatura.save
        format.html { redirect_to(@ponto_assinatura, :notice => 'Ponto assinatura cadastrado com sucesso.') }
        format.xml  { render :xml => @ponto_assinatura, :status => :created, :location => @ponto_assinatura }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ponto_assinatura.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ponto_assinaturas/1
  # PUT /ponto_assinaturas/1.xml
  def update
    @ponto_assinatura = PontoAssinatura.find(params[:id])

    respond_to do |format|
      if @ponto_assinatura.update_attributes(params[:ponto_assinatura])
        format.html { redirect_to(@ponto_assinatura, :notice => 'Ponto assinatura atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ponto_assinatura.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ponto_assinaturas/1
  # DELETE /ponto_assinaturas/1.xml
  def destroy
    @ponto_assinatura = PontoAssinatura.find(params[:id])
    @ponto_assinatura.destroy

    respond_to do |format|
      format.html { redirect_to(ponto_assinaturas_url) }
      format.xml  { head :ok }
    end
  end
  private
  def ponto_assinatura_dados
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.find(params[:funcionario_id])
    @ponto_diario = @funcionarios.ponto_diarios.find(params[:ponto_diario_id])
  end
end
