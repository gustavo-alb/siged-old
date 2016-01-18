# -*- encoding : utf-8 -*-
class Folha::FinanceirosController < ApplicationController
  load_and_authorize_resource :class=> Folha::Financeiro
  # GET /folha/financeiros
  # GET /folha/financeiros.xml
  before_filter :folha_padrao,:except=>[:auto_complete_for_folha_financeiro_funcionario_id,:validar_matricula,:validar_evento,:auto_complete_for_folha_financeiro_evento_id]
  def index
    #@search = Folha::Financeiro.scoped_search(params[:search])
    @folha_financeiros = Folha::Financeiro.da_folha(@folha).paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folha_financeiros }
    end
  end

  # GET /folha/financeiros/1
  # GET /folha/financeiros/1.xml
  def show
    @folha_financeiro = Folha::Financeiro.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folha_financeiro }
    end
  end



  # GET /folha/financeiros/new
  # GET /folha/financeiros/new.xml
  def new
    @folha_financeiro = Folha::Financeiro.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folha_financeiro }
    end
  end

  def auto_complete_for_folha_financeiro_funcionario_id
    matricula=params[:folha_financeiro][:funcionario_id]
    @funcionarios = Funcionario.find(:all,
                                     :conditions => [ 'LOWER(matricula) iLIKE ?',
                                                      '%' + matricula.downcase + '%' ])
    render :partial => "busca_matriculas"

  end


  def auto_complete_for_folha_financeiro_evento_id
    evento=params[:folha_financeiro][:evento_id]
    @eventos = Folha::Evento.find(:all,
                                  :conditions => [ 'LOWER(codigo) iLIKE ?',
                                                   '%' + evento.downcase + '%' ])
    render :partial => "busca_eventos"

  end

  def validar_evento
    @evento = Folha::Evento.find(params[:financeiro_id])

    render :update do |page|
      page.visual_effect :highlight,"evento"
      page.replace_html "evento", :partial=>"evento"
      page.replace_html "nome_evento", :partial=>"nome_evento"
    end
  end

  def validar_matricula
    @funcionario = Funcionario.find_by_matricula(params[:financeiro_id])

    render :update do |page|
      page.visual_effect :highlight,"matricula"
      page.visual_effect :highlight,"nome_funcionario"
      page.replace_html "matricula", :partial=>"matricula"
      page.replace_html "nome_funcionario", :partial=>"nome_funcionario"
    end
  end
  # GET /folha/financeiros/1/edit
  def edit
    @folha_financeiro = Folha::Financeiro.find(params[:id])
  end

  # POST /folha/financeiros
  # POST /folha/financeiros.xml
  def create
    @folha_financeiro = Folha::Financeiro.new(params[:folha_financeiro])

    respond_to do |format|
      if @folha_financeiro.save
        format.html { redirect_to(folha_folha_financeiros_url(@folha), :notice => 'Financeiro cadastrado com sucesso.') }
        format.xml  { render :xml => @folha_financeiro, :status => :created, :location => @folha_financeiro }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folha_financeiro.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /folha/financeiros/1
  # PUT /folha/financeiros/1.xml
  def update
    @folha_financeiro = Folha::Financeiro.find(params[:id])

    respond_to do |format|
      if @folha_financeiro.update_attributes(params[:folha_financeiro])
        format.html { redirect_to(folha_folha_financeiros_url(@folha), :notice => 'Financeiro atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @folha_financeiro.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /folha/financeiros/1
  # DELETE /folha/financeiros/1.xml
  def destroy
    @folha_financeiro = Folha::Financeiro.find(params[:id])
    @folha_financeiro.destroy

    respond_to do |format|
      format.html { redirect_to(:back,:alert=>"Apagado com sucesso.") }
      format.xml  { head :ok }
    end
  end

  private
  def folha_padrao
    @folha = Folha::Folha.find(params[:folha_id])
  end
  def entidade_id
  end
end
