# -*- encoding : utf-8 -*-
class CarenciasController < ApplicationController
  # GET /carencias
  # GET /carencias.xml
  before_filter :ano_letivo
  load_and_authorize_resource




  # def auto_complete_for_escola_nome
  #   @escolas = Escola.find(:all,
  #     :conditions => [ 'LOWER(nome) iLIKE ?',
  #       '%' + params[:escola][:nome].downcase + '%' ])
  #   render :partial => "busca_escolas"
  # end


  # def auto_complete_for_disciplina_nome
  #   @disciplinas = Disciplina.find(:all,
  #     :conditions => [ 'LOWER(nome) iLIKE ?',
  #       '%' + params[:disciplina][:nome].downcase + '%' ])
  #   render :partial => "busca_disciplinas"
  # end

  def index

    @carencias = @ano_letivo.carencias.all.paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @carencias }
    end
  end

  # GET /carencias/1
  # GET /carencias/1.xml
  def show
    @carencia = Carencia.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @carencia }
    end
  end

  # GET /carencias/new
  # GET /carencias/new.xml
  def new
    @carencia = Carencia.new
    @carencias = @ano_letivo.carencias
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @carencia }
    end
  end

  # GET /carencias/1/edit
  def edit
    @carencia = Carencia.find(params[:id])

  end

  # POST /carencias
  # POST /carencias.xml
  def create
    @carencia = Carencia.new(params[:carencia])

    respond_to do |format|
      if @ano_letivo.save!
        format.html { redirect_to(ano_letivo_carencia_path(@ano_letivo,carencia), :notice => 'Carencia cadastrado com sucesso.') }
        format.xml  { render :xml => @ano_letivo, :status => :created, :location => @ano_letivo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ano_letivo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /carencias/1
  # PUT /carencias/1.xml
  def update
    @carencia = Carencia.find(params[:id])

    respond_to do |format|
      if @carencia.update_attributes(params[:carencia])
        format.html { redirect_to(@carencia, :notice => 'Carencia atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @carencia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /carencias/1
  # DELETE /carencias/1.xml
  def destroy
    @carencia = Carencia.find(params[:id])
    @carencia.destroy

    respond_to do |format|
      format.html { redirect_to(carencias_url(@ano_letivo)) }
      format.xml  { head :ok }
    end
  end

  private
  def ano_letivo
    @ano_letivo = AnoLetivo.find_by_ano(Date.today.year)
  end
end
