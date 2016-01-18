# -*- encoding : utf-8 -*-
class AmbientesController < ApplicationController
  load_and_authorize_resource
  # GET /ambientes
  # GET /ambientes.xml
  before_filter :dados_essenciais,:except=>[:matrizes]
  def index
    @escola = Escola.find_by_slug(params[:escola_id])
    @ambientes = @escola.ambientes.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ambientes }
    end
  end

  # GET /ambientes/1
  # GET /ambientes/1.xml
  def show
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ambiente }
    end
  end

  # GET /ambientes/new
  # GET /ambientes/new.xml
  def new
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ambiente }
    end
  end

  # GET /ambientes/1/edit
  def edit
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find(params[:id])
  end

  # POST /ambientes
  # POST /ambientes.xml
  def create
    @escola = Escola.find params[:escola_id]
    @ambiente =@escola.ambientes.new(params[:ambiente])

    respond_to do |format|
      if @ambiente.save
        format.html { redirect_to(escola_ambiente_url(@escola,@ambiente), :notice => 'Ambiente cadastrado com sucesso.') }
        format.xml  { render :xml => @ambiente, :status => :created, :location => @ambiente }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ambiente.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ambientes/1
  # PUT /ambientes/1.xml
  def update
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find(params[:id])
    respond_to do |format|
      if @ambiente.update_attributes(params[:ambiente])
        format.html { redirect_to(escola_ambiente_url(@escola,@ambiente), :notice => 'Ambiente atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ambiente.errors, :status => :unprocessable_entity }
      end
    end
  end

  def incluir_turma
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find(params[:ambiente_id])
    @turma = @ambiente.turmas.new
    @matrizes = @escola.matrizes.collect{|m|[m.codigo,m.id]}
    render :update do |page|
      page.visual_effect :highlight,"turma"
      page.replace_html "turma", :partial=>"turma"
    end
  end


  def incluir_ambiente_fisico
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @ambiente_fisico = @ambiente.ambientes_fisicos.new
    @matrizes = @escola.matrizes.collect{|m|[m.codigo,m.id]}
    render :update do |page|
      page.visual_effect :highlight,"turma"
      page.replace_html "turma", :partial=>"ambientes_fisicos"
    end
  end


  def salvar_turma
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @turma = @ambiente.turmas.new(params[:turma])
    if @turma.save
      @turmas = Turma.find(:all,:joins=>[:serie],:conditions=>["ambiente_id= ? and escola_id = ?",@ambiente.id,@escola.id],:order => 'turno,series.nome')
      render :update do |page|
        page.visual_effect :highlight,"matriz"
        page.replace_html "turma", :partial=>"listar_turmas", :notice => 'Ambiente atualizado com sucesso.'
      end
    else
      render :update do |page|
        page.replace_html "turma", :partial=>"erro_turma",:locals=>{:f=>@turma}
        page.visual_effect :highlight,"matriz"
      end
    end
  end

  def salvar_ambiente_fisico
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @ambiente_fisico = @ambiente.ambientes_fisicos.new(params[:ambiente_fisico])
    if @ambiente_fisico.save
      @ambientes_fisicos = @ambiente.ambientes_fisicos.all
      render :update do |page|
        page.replace_html "turma", :partial=>"listar_ambientes_fisicos", :notice => 'Ambiente atualizado com sucesso.'
      end
    end
  end

  def excluir_turma
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @turma = @ambiente.turmas.find(params[:turma_id])
    @turmas = @ambiente.turmas.all
    if @turma.destroy
      render :update do |page|
        page.reload()
      end
    end
  end

  def excluir_ambiente_fisico
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @ambiente_fisico = @ambiente.ambientes_fisicos.new(params[:ambiente_fisico])
    @turmas = @ambiente.ambientes_fisicos.all
    render :update do |page|
      page.reload()
    end
  end



  def matrizes
    @escola = Escola.find(params[:escola_id])
    if !params[:matrix].blank?
      @matriz = Matriz.find(params[:matrix])
      @series = @matriz.series.order(:nome).collect{|s|[s.nome,s.id]}
      render :partial=>"matriz"
    else
      render :nothing=>true
    end
  end

  def configurar_ambiente
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @turmas = Turma.find(:all,:joins=>[:serie],:conditions=>["ambiente_id= ? and escola_id = ?",@ambiente.id,@escola.id],:order => 'turno,series.nome')
    #@turmas = @ambiente.turmas.join(:serie).order("serie.nome").all
  end

  def configurar_ambiente_fisico
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find params[:ambiente_id]
    @ambientes_fisicos = @ambiente.ambientes_fisicos.all
  end
  # DELETE /ambientes/1
  # DELETE /ambientes/1.xml
  def destroy
    @escola = Escola.find params[:escola_id]
    @ambiente = @escola.ambientes.find(params[:id])
    @ambiente.destroy

    respond_to do |format|
      format.html { redirect_to(escola_ambientes_url(@escola)) }
      format.xml  { head :ok }
    end
  end
end
