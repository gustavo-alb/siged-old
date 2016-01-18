# -*- encoding : utf-8 -*-
class PontoDiariosController < ApplicationController
  load_and_authorize_resource
  # GET /ponto_diarios
  # GET /ponto_diarios.xml
  before_filter :ponto_diarios_dados
  before_filter :ponto_assinatura_dados,:only=>[:assinar_ponto]
  def index
    @ponto_diarios = PontoDiario.do_ano(Time.now.year).do_mes(Time.now.month).all.paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ponto_diarios }
    end
  end

  # GET /ponto_diarios/1
  # GET /ponto_diarios/1.xml
  def show
    @ponto_diario = PontoDiario.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ponto_diario }
    end
  end

  # GET /ponto_diarios/new
  # GET /ponto_diarios/new.xml
  def new
    @ponto_diario = PontoDiario.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ponto_diario }
    end
  end

  # GET /ponto_diarios/1/edit
  def edit
    @ponto_diario = PontoDiario.find(params[:id])
  end

  # POST /ponto_diarios
  # POST /ponto_diarios.xml
  def create
    @ponto_diario = PontoDiario.new(params[:ponto_diario])

    respond_to do |format|
      if @ponto_diario.save
        format.html { redirect_to(@ponto_diario, :notice => 'Ponto diario cadastrado com sucesso.') }
        format.xml  { render :xml => @ponto_diario, :status => :created, :location => @ponto_diario }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ponto_diario.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ponto_diarios/1
  # PUT /ponto_diarios/1.xml
  def update
    @ponto_diario = PontoDiario.find(params[:id])

    respond_to do |format|
      if @ponto_diario.update_attributes(params[:ponto_diario])
        format.html { redirect_to(@ponto_diario, :notice => 'Ponto diario atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ponto_diario.errors, :status => :unprocessable_entity }
      end
    end
  end
  def assinar_ponto
    @assinatura =@ponto_diario.ponto_assinaturas.do_ano(Time.now.year).do_mes(Time.now.month).do_dia(Time.now.day).first
  end
  # DELETE /ponto_diarios/1
  # DELETE /ponto_diarios/1.xml
  def destroy
    @ponto_diario = PontoDiario.find(params[:id])
    @ponto_diario.destroy

    respond_to do |format|
      format.html { redirect_to(ponto_diarios_url) }
      format.xml  { head :ok }
    end
  end
  private
  def ponto_diarios_dados
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.find(params[:funcionario_id])
  end
  def ponto_assinatura_dados
    @pessoa = Pessoa.find(params[:pessoa_id])
    @funcionario = @pessoa.funcionarios.find(params[:funcionario_id])
    @ponto_diario = @funcionario.ponto_diarios.find(params[:ponto_diario_id])
  end
end
