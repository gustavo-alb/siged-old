# -*- encoding : utf-8 -*-
class DisciplinaContratacoesController < ApplicationController
  # GET /disciplina_contratacoes
  # GET /disciplina_contratacoes.xml
  def index
    @q = DisciplinaContratacao.ransack(params[:q])
    @disciplina_contratacoes = @q.result.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @disciplina_contratacoes }
    end
  end

  # GET /disciplina_contratacoes/1
  # GET /disciplina_contratacoes/1.xml
  def show
    @disciplina_contratacao = DisciplinaContratacao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @disciplina_contratacao }
    end
  end

  # GET /disciplina_contratacoes/new
  # GET /disciplina_contratacoes/new.xml
  def new
    @disciplina_contratacao = DisciplinaContratacao.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @disciplina_contratacao }
    end
  end

  # GET /disciplina_contratacoes/1/edit
  def edit
    @disciplina_contratacao = DisciplinaContratacao.find(params[:id])
  end

  # POST /disciplina_contratacoes
  # POST /disciplina_contratacoes.xml
  def create
    @disciplina_contratacao = DisciplinaContratacao.new(params[:disciplina_contratacao])

    respond_to do |format|
      if @disciplina_contratacao.save
        format.html { redirect_to(@disciplina_contratacao, :notice => 'Disciplina contratacao cadastrado com sucesso.') }
        format.xml  { render :xml => @disciplina_contratacao, :status => :created, :location => @disciplina_contratacao }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @disciplina_contratacao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /disciplina_contratacoes/1
  # PUT /disciplina_contratacoes/1.xml
  def update
    @disciplina_contratacao = DisciplinaContratacao.find(params[:id])

    respond_to do |format|
      if @disciplina_contratacao.update_attributes(params[:disciplina_contratacao])
        format.html { redirect_to(@disciplina_contratacao, :notice => 'Disciplina contratacao atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @disciplina_contratacao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /disciplina_contratacoes/1
  # DELETE /disciplina_contratacoes/1.xml
  def destroy
    @disciplina_contratacao = DisciplinaContratacao.find(params[:id])
    @disciplina_contratacao.destroy

    respond_to do |format|
      format.html { redirect_to(disciplina_contratacoes_url) }
      format.xml  { head :ok }
    end
  end
end
