# -*- encoding : utf-8 -*-
class Administracao::TarefasController < ApplicationController
  # GET /administracao/tarefas
  # GET /administracao/tarefas.xml
  def index
    #@search = Administracao::Tarefa.scoped_search(params[:search])
    @administracao_tarefas =  Administracao::Tarefa.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administracao_tarefas }
    end
  end

  def funcionarios
    @entidade = Entidade.find 1
    @funcionarios = Funcionario.da_entidade(1).find(:all, :joins =>[:pessoa],:order => 'pessoas.nome')

  end

  # GET /administracao/tarefas/1
  # GET /administracao/tarefas/1.xml
  def show
    @administracao_tarefa = Administracao::Tarefa.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administracao_tarefa }
    end
  end

  # GET /administracao/tarefas/new
  # GET /administracao/tarefas/new.xml
  def new
    @administracao_tarefa = Administracao::Tarefa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administracao_tarefa }
    end
  end

  def atributos
    $classe = params[:classe]
    if !$classe.blank?
      @atributos = Kernel.const_get($classe).new.attributes.collect{|a|a.first}
      render :partial=>'atributos'
    else
      render :partial=>'blank'
    end
  end

  def verificar_atributo
    @classe = $classe
    @atributo = params[:attrib]
    if !@classe.blank?
      if  Kernel.const_get($classe).testar_relacionamento(@atributo)
        r = @atributo[0,@atributo.size-3]
        relac = r.camelize
        if Kernel.const_get(relac).last.respond_to?('nome')
          @objetos = Kernel.const_get(relac).all.collect{|a|[a.nome,a.id]}
        elsif Kernel.const_get(relac).last.respond_to?('nome')
          @objetos = Kernel.const_get(relac).all.collect{|a|[a.nome,a.id]}
        elsif Kernel.const_get(relac).last.respond_to?('codigo')
          @objetos = Kernel.const_get(relac).all.collect{|a|[a.codigo,a.id]}
        else
          @objetos = Kernel.const_get(relac).all.collect{|a|[a.id,a.id]}

        end
      end
      render :partial=>'tipo'
    else
      render :partial=>'blank'
    end

  end

  # GET /administracao/tarefas/1/edit
  def edit
    @administracao_tarefa = Administracao::Tarefa.find(params[:id])
  end

  # POST /administracao/tarefas
  # POST /administracao/tarefas.xml
  def create
    @administracao_tarefa = Administracao::Tarefa.new(params[:administracao_tarefa])

    respond_to do |format|
      if @administracao_tarefa.save
        format.html { redirect_to(@administracao_tarefa, :notice => 'Tarefa cadastrado com sucesso.') }
        format.xml  { render :xml => @administracao_tarefa, :status => :created, :location => @administracao_tarefa }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administracao_tarefa.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /administracao/tarefas/1
  # PUT /administracao/tarefas/1.xml
  def update
    @administracao_tarefa = Administracao::Tarefa.find(params[:id])

    respond_to do |format|
      if @administracao_tarefa.update_attributes(params[:administracao_tarefa])
        format.html { redirect_to(@administracao_tarefa, :notice => 'Tarefa atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administracao_tarefa.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administracao/tarefas/1
  # DELETE /administracao/tarefas/1.xml
  def destroy
    @administracao_tarefa = Administracao::Tarefa.find(params[:id])
    @administracao_tarefa.destroy

    respond_to do |format|
      format.html { redirect_to(administracao_tarefas_url) }
      format.xml  { head :ok }
    end
  end
end
