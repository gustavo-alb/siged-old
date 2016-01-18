# -*- encoding : utf-8 -*-
class EnquetesController < ApplicationController
  # GET /enquetes
  # GET /enquetes.xml
  def index
    @enquetes = Enquete.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @enquetes }
    end
  end

  # GET /enquetes/1
  # GET /enquetes/1.xml
  def show
    @enquete = Enquete.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @enquete }
    end
  end

  # GET /enquetes/new
  # GET /enquetes/new.xml
  def new
    @enquete = Enquete.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @enquete }
    end
  end

  # GET /enquetes/1/edit
  def edit
    @enquete = Enquete.find(params[:id])
  end

  # POST /enquetes
  # POST /enquetes.xml
  def create
    @enquete = Enquete.new(params[:enquete])

    respond_to do |format|
      if @enquete.save
        format.html { redirect_to(@enquete, :notice => 'Enquete cadastrado com sucesso.') }
        format.xml  { render :xml => @enquete, :status => :created, :location => @enquete }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @enquete.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /enquetes/1
  # PUT /enquetes/1.xml
  def update
    @enquete = Enquete.find(params[:id])

    respond_to do |format|
      if @enquete.update_attributes(params[:enquete])
        format.html { redirect_to(@enquete, :notice => 'Enquete atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @enquete.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /enquetes/1
  # DELETE /enquetes/1.xml
  def destroy
    @enquete = Enquete.find(params[:id])
    @enquete.destroy

    respond_to do |format|
      format.html { redirect_to(enquetes_url) }
      format.xml  { head :ok }
    end
  end
end
