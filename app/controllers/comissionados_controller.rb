# -*- encoding : utf-8 -*-
class ComissionadosController < ApplicationController
  load_and_authorize_resource
  # GET /comissionados
  # GET /comissionados.xml

  def index
    @search = Comissionado.scoped_search(params[:search])
    @comissionados = @search.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comissionados }
    end
  end

  def tipo_destino
    @destinos = TipoDestino.all.collect{|t|[t.nome,t.id]}
    render :partial=>'tipo'
  end

  def destino
    if params[:tp_destino].size>0
      @destino = TipoDestino.find(params[:tp_destino])
      case @destino.nome
      when 'Escola'
        render :partial=>'escola'
      when 'Departamento'
        render :partial=>'departamento'
      end
    else
      render :partial=>'blank'
    end
  end

  def auto_complete_for_escola_nome
    @escolas = Escola.find(:all,
                           :conditions => [ 'LOWER(nome) iLIKE ?',
                                            '%' + params[:escola][:nome].downcase + '%' ])
    render :partial => "busca_escolas"

  end

  def auto_complete_for_departamento_nome
    @departamentos = Departamento.find(:all,
                                       :conditions => [ 'LOWER(nome) iLIKE ?',
                                                        '%' + params[:departamento][:nome].downcase + '%' ])
    render :partial => "busca_departamentos"

  end



  # GET /comissionados/1
  # GET /comissionados/1.xml
  def show
    @comissionado = Comissionado.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comissionado }
    end
  end

  def exonerar_comissionado
    @comissionado = Comissionado.find(params[:comissionado_id])
    @funcionario = Funcionario.find(@comissionado.funcionario_id)
    @pessoa = @funcionario.pessoa
    render :layout=>"facebox"

    #redirect_to(pessoa_funcionario_url(@pessoa,@funcionario), :notice => 'Comissionado exonerado com sucesso.')
  end

  def salvar_exoneracao
    @funcionario = Funcionario.find(params[:comissionado][:funcionario_id])
    @pessoa = @funcionario.pessoa
    @comissionado = Comissionado.find(params[:comissionado_id])
    @comissionado.exonerar(params[:data_exoneracao],params[:decreto_exoneracao])
    redirect_to pessoa_funcionario_path(@pessoa,@funcionario), :notice => 'Funcionário Devolvido ao NUPES'
  end


  # GET /comissionados/new
  # GET /comissionados/new.xml
  def new
    @comissionado = Comissionado.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comissionado }
    end
  end

  # GET /comissionados/1/edit
  def edit
    @comissionado = Comissionado.find(params[:id])
  end

  # POST /comissionados
  # POST /comissionados.xml
  # def create
  #   @funcionario = Funcionario.find(params[:comissionado][:funcionario_id])
  #   @pessoa = @funcionario.pessoa
  #   @comissionado = @funcionario.comissionados.new(params[:comissionado])
  #   if !params[:comissionado][:tipo_destino_id].blank? and !params[:escola].nil?
  #     @escola = Escola.find (:first,:conditions=>["nome ilike ?",params[:escola][:nome]])
  #     @comissionado.escola_id = @escola.id
  #   elsif !params[:comissionado][:tipo_destino_id].blank? and !params[:departamento].nil?
  #     @departamento = Departamento.find(:first,:conditions=>["nome ilike ?",params[:departamento][:nome]])
  #     @comissionado.departamento_id = @departamento.id
  #   end
  #   respond_to do |format|
  #     if @comissionado.save
  #       format.html { redirect_to(pessoa_funcionario_url(@pessoa,@funcionario), :notice => 'Comissionado cadastrado com sucesso.') }
  #       format.xml  { render :xml => @comissionado, :status => :created, :location => @comissionado }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @comissionado.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /comissionados/1
  # PUT /comissionados/1.xml
  def update
    @comissionado = Comissionado.find(params[:id])


    respond_to do |format|
      if @comissionado.update_attributes(params[:comissionado])
        format.html { redirect_to(:back, :notice => 'Comissionado atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comissionado.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comissionados/1
  # DELETE /comissionados/1.xml
  def destroy
    @comissionado = Comissionado.find(params[:id])
    @funcionario = @comissionado.funcionario
    @comissionado.destroy
    @pessoa = @funcionario.pessoa
    respond_to do |format|
      format.html { redirect_to(:back, :notice => 'Comissionado apagado com sucesso.') }
      format.xml  { head :ok }
    end
  end
  private
  def funcionario
    @funcionario = Funcionario.find(params[:funcionario_id])
    @pessoa = Pessoa.find(params[:pessoa_id])
    @escolas = Escola.all.collect{|p| [p.nome,p.id]}
  end
end
