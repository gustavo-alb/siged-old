# -*- encoding : utf-8 -*-
class OrgaosController < ApplicationController
  load_and_authorize_resource
  # GET /orgaos
  # GET /orgaos.xml

  before_filter :dados_essenciais
  def index
    @q = Orgao.ransack(params[:q])
    @orgaos = @q.result(distinct: true).paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orgaos }
    end
  end

  def agenda
    @orgao = Orgao.find(params[:orgao_id])
    @departamentos = @orgao.departamentos.order(:hierarquia)#.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 20
    respond_to do |format|
      format.html # index.html.erb
      format.pdf do
        render :pdf =>"agenda - #{@orgao.nome.downcase}",
          :layout => "pdf", # OPTIONAL
          :wkhtmltopdf=>"/usr/bin/wkhtmltopdf",
          :zoom => 0.8 ,
          :orientation => 'Landscape'
      end
    end
  end

  # GET /orgaos/1
  # GET /orgaos/1.xml
  def show
    @orgao = Orgao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @orgao }
    end
  end

  def funcionarios
    @orgao = Orgao.find(params[:orgao_id])
    @funcionarios = @orgao.funcionarios.joins(:lotacoes).where("lotacaos.finalizada = ? and lotacaos.ativo = ?",true,true).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 8
    #@cargos_principais = Cargo.where("id in (?)",[Cargo.find_by_nome("PEDAGOGO").id,Cargo.find_by_nome("PROFESSOR").id,Cargo.find_by_nome("ESPECIALISTA DE EDUCACAO").id,Cargo.find_by_nome("AUXILIAR EDUCACIONAL").id,Cargo.find_by_nome("CUIDADOR").id,Cargo.find_by_nome("INTERPRETE").id]).order(:nome)
    #@outros_cargos = Cargo.where("id not in (?)",@cargos_principais).order(:nome)
    #@funcionarios_cargos_principais = @orgao.funcionarios.where("cargo_id in (?)",@cargos_principais).group_by{|t|t.cargo}
    #@funcionarios_outros = @orgao.funcionarios.where("cargo_id in (?)",@outros_cargos)
    @encaminhados = @orgao.funcionarios.joins(:lotacoes).where("lotacaos.finalizada = ? and lotacaos.ativo = ?",false,true)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /orgaos/new
  # GET /orgaos/new.xml
  def new
    @url = orgaos_url
    @orgao = Orgao.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @orgao }
    end
  end

  # GET /orgaos/1/edit
  def edit
    @url = orgao_url
    @orgao = Orgao.find(params[:id])
  end

  # POST /orgaos
  # POST /orgaos.xml
  def create
    @orgao = Orgao.new(params[:orgao])

    respond_to do |format|
      if @orgao.save
        format.html { redirect_to(@orgao, :notice => 'Orgão cadastrado com sucesso.') }
        format.xml  { render :xml => @orgao, :status => :created, :location => @orgao }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @orgao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orgaos/1
  # PUT /orgaos/1.xml
  def update
    @orgao = Orgao.find(params[:id])

    respond_to do |format|
      if @orgao.update_attributes(params[:orgao])
        format.html { redirect_to(@orgao, :notice => 'Orgão atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @orgao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orgaos/1
  # DELETE /orgaos/1.xml
  def destroy
    @orgao = Orgao.find(params[:id])
    @orgao.destroy

    respond_to do |format|
      format.html { redirect_to(orgaos_url) }
      format.xml  { head :ok }
    end
  end
end
