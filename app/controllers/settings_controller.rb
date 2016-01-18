# -*- encoding : utf-8 -*-
class SettingsController < ApplicationController
  load_and_authorize_resource
  # GET /settings
  # GET /settings.xml
  #auto_complete_for :pessoa, :nome
  before_filter :escola,:dados_essenciais,:except=>[:tipo,:busca,:auto_complete_for_supervisor_nome,:auto_complete_for_secretario_nome,:auto_complete_for_diretor_nome]
  #before_filter {objs("DIRECAO")}

  def index
    #@search = .scoped_search(params[:search])
    @settings = Setting.da_escola(@escola.id).all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @settings }
    end
  end

  def busca
    @pessoas = Pessoa.find(:all,:conditions=>['nome iLIKE ? ',"%#{params[:nome]}%"])
    render :partial=>"busca"
  end

  def tipo
    tipo = params[:tipo]
    if tipo=="DIRECAO"
      @objeto = Pessoa.diretores.all.collect{|p|[p.nome,p.id]}
      @titulo = "Diretor (a)"
      render :partial=>'direcao'
    elsif tipo=="SECRETARIA"
      @objeto = Pessoa.secretarios.all.collect{|p|[p.nome,p.id]}
      @titulo = "Secretario (a)"
      render :partial=>'secretaria'
    elsif tipo=="SUPERVISAO"
      @objeto = Pessoa.supervisores.all.collect{|p|[p.nome,p.id]}
      @titulo = "Supervisor (a)"
      render :partial=>'secretaria'
    elsif tipo=="MATRIZ"
      @objeto = Matriz.all.collect{|m|[m.codigo,m.id]}
      @titulo = "Matriz"
      render :partial=>'matriz'
    else
      render :partial=>"blank"
    end
  end

  # GET /settings/1
  # GET /settings/1.xml
  def show
    @setting = Setting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @setting }
    end
  end

  # GET /settings/new
  # GET /settings/new.xml
  def new
    @setting = Setting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @setting }
    end
  end

  # GET /settings/1/edit
  def edit
    @setting = Setting.find(params[:id])
  end

  # POST /settings
  # POST /settings.xml
  def create
    @setting = Setting.new(params[:setting])

    respond_to do |format|
      if @setting.save
        format.html { redirect_to(escola_ano_letivo_setting_url(@escola,@ano_letivo,@setting), :notice => 'Setting cadastrado com sucesso.') }
        format.xml  { render :xml => @setting, :status => :created, :location => @setting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /settings/1
  # PUT /settings/1.xml
  def update
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        format.html { redirect_to(escola_ano_letivo_setting_url(@escola,@ano_letivo,@setting), :notice => 'Setting atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @settings.errors, :status => :unprocessable_entity }
      end
    end
  end

  def auto_complete_for_secretario_nome
    @pessoas = Pessoa.secretarios.find(:all,
                                       :conditions => [ 'LOWER(nome) LIKE ?',
                                                        '%' + params[:secretario][:nome].downcase + '%' ])
    render :partial => "busca"

  end

  def auto_complete_for_diretor_nome
    @pessoas = Pessoa.diretores.find(:all,
                                     :conditions => [ 'LOWER(nome) LIKE ?',
                                                      '%' + params[:diretor][:nome].downcase + '%' ])
    render :partial => "busca"

  end

  def auto_complete_for_supervisor_nome
    @pessoas = Pessoa.supervisores.find(:all,
                                        :conditions => [ 'LOWER(nome) LIKE ?',
                                                         '%' + params[:supervisor][:nome].downcase + '%' ])
    render :partial => "busca"

  end

  # DELETE /settings/1
  # DELETE /settings/1.xml
  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy

    respond_to do |format|
      format.html { redirect_to(escola_ano_letivo_settings_url) }
      format.xml  { head :ok }
    end
  end

  private


  def escola
    @escola = Escola.find(params[:escola_id])
    @ano_letivo = @escola.anos_letivos.find(params[:ano_letivo_id])
  end
end
