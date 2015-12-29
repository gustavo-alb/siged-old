# -*- encoding : utf-8 -*-
class NiveisEnsinosController < ApplicationController
  # GET /niveis_ensinos
  # GET /niveis_ensinos.xml
  def index
    @q = NiveisEnsino.ransack(params[:q])
    @niveis_ensinos = @q.result.order('nome asc').paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @niveis_ensinos }
    end
  end

  # GET /niveis_ensinos/1
  # GET /niveis_ensinos/1.xml
  def show
    @niveis_ensino = NiveisEnsino.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @niveis_ensino }
    end
  end

  # GET /niveis_ensinos/new
  # GET /niveis_ensinos/new.xml
  def new
    @niveis_ensino = NiveisEnsino.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @niveis_ensino }
    end
  end

  # GET /niveis_ensinos/1/edit
  def edit
    @niveis_ensino = NiveisEnsino.find(params[:id])
  end

  # POST /niveis_ensinos
  # POST /niveis_ensinos.xml
  def create
    @niveis_ensino = NiveisEnsino.new(params[:niveis_ensino])

    respond_to do |format|
      if @niveis_ensino.save
        format.html { redirect_to(@niveis_ensino, :notice => 'Niveis ensino cadastrado com sucesso.') }
        format.xml  { render :xml => @niveis_ensino, :status => :created, :location => @niveis_ensino }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @niveis_ensino.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /niveis_ensinos/1
  # PUT /niveis_ensinos/1.xml
  def update
    @niveis_ensino = NiveisEnsino.find(params[:id])

    respond_to do |format|
      if @niveis_ensino.update_attributes(params[:niveis_ensino])
        format.html { redirect_to(@niveis_ensino, :notice => 'Niveis ensino atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @niveis_ensino.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /niveis_ensinos/1
  # DELETE /niveis_ensinos/1.xml
  def destroy
    @niveis_ensino = NiveisEnsino.find(params[:id])
    @niveis_ensino.destroy

    respond_to do |format|
      format.html { redirect_to(niveis_ensinos_url) }
      format.xml  { head :ok }
    end
  end
end
