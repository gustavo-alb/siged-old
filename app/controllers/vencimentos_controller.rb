# -*- encoding : utf-8 -*-
class VencimentosController < ApplicationController
  # GET /vencimentos
  # GET /vencimentos.xml
  load_and_authorize_resource
  before_filter :nivel

  def index
    #@search = Vencimento.scoped_search(params[:search])
    @vencimentos = Vencimento.do_nivel(@nivel.id).paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vencimentos }
    end
  end

  # GET /vencimentos/1
  # GET /vencimentos/1.xml
  def show
    @vencimento = Vencimento.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vencimento }
    end
  end

  # GET /vencimentos/new
  # GET /vencimentos/new.xml
  def new
    @vencimento = Vencimento.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vencimento }
    end
  end

  # GET /vencimentos/1/edit
  def edit
    @vencimento = Vencimento.find(params[:id])
  end

  # POST /vencimentos
  # POST /vencimentos.xml
  def create
    @vencimento = Vencimento.new(params[:vencimento])

    respond_to do |format|
      if @vencimento.save
        format.html { redirect_to(referencia_nivel_vencimento_path(@nivel,@vencimento), :notice => 'Vencimento cadastrado com sucesso.') }
        format.xml  { render :xml => @vencimento, :status => :created, :location => @vencimento }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @vencimento.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /vencimentos/1
  # PUT /vencimentos/1.xml
  def update
    @vencimento = Vencimento.find(params[:id])

    respond_to do |format|
      if @vencimento.update_attributes(params[:vencimento])
        format.html { redirect_to(referencia_nivel_vencimento_path(@nivel,@vencimento), :notice => 'Vencimento atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vencimento.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /vencimentos/1
  # DELETE /vencimentos/1.xml
  def destroy
    @vencimento = Vencimento.find(params[:id])
    @vencimento.destroy

    respond_to do |format|
      format.html { redirect_to(referencia_nivel_vencimentos_path(@nivel)) }
      format.xml  { head :ok }
    end
  end
end
private
def nivel
  @nivel = ReferenciaNivel.find(params[:referencia_nivel_id])
end
