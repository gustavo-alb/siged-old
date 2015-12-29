# -*- encoding : utf-8 -*-
class ReferenciaNiveisController < ApplicationController
  load_and_authorize_resource
  # GET /referencia_niveis
  # GET /referencia_niveis.xml
  def index
    @q = ReferenciaNivel.ransack(params[:q])
    @referencia_niveis = @q.result.order(:codigo).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @referencia_niveis }
    end
  end

  # GET /referencia_niveis/1
  # GET /referencia_niveis/1.xml
  def show
    @referencia_nivei = ReferenciaNivel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @referencia_nivei }
    end
  end

  # GET /referencia_niveis/new
  # GET /referencia_niveis/new.xml
  def new
    @referencia_nivei = ReferenciaNivel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @referencia_nivei }
    end
  end

  # GET /referencia_niveis/1/edit
  def edit
    @referencia_nivei = ReferenciaNivel.find(params[:id])
  end

  # POST /referencia_niveis
  # POST /referencia_niveis.xml
  def create
    @referencia_nivei = ReferenciaNivel.new(params[:referencia_nivel])

    respond_to do |format|
      if @referencia_nivei.save
        format.html { redirect_to(@referencia_nivei, :notice => 'Nível cadastrado com sucesso.') }
        format.xml  { render :xml => @referencia_nivei, :status => :created, :location => @referencia_nivei }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @referencia_nivei.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /referencia_niveis/1
  # PUT /referencia_niveis/1.xml
  def update
    @referencia_nivei = ReferenciaNivel.find(params[:id])

    respond_to do |format|
      if @referencia_nivei.update_attributes(params[:referencia_nivel])
        format.html { redirect_to(@referencia_nivei, :notice => 'Nível atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @referencia_nivei.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /referencia_niveis/1
  # DELETE /referencia_niveis/1.xml
  def destroy
    @referencia_nivei = ReferenciaNivel.find(params[:id])
    @referencia_nivei.destroy

    respond_to do |format|
      format.html { redirect_to(referencia_niveis_url) }
      format.xml  { head :ok }
    end
  end
end
