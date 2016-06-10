# -*- encoding : utf-8 -*-
class UsuariosController < ApplicationController
  before_filter :grupos
  # GET /users
  # GET /users.xml
  load_and_authorize_resource
  def index
    @q = User.ransack(params[:q])
    if params[:q].blank?
    @usuarios = User.order("name asc").paginate :page => params[:page], :per_page => 10
    else
    @usuarios = @q.result(distinct: true).order('name ASC').paginate :page => params[:page], :per_page => 10
  end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = Usuario.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = Usuario.new
    @entidades = Entidade.all.collect{|e|[e.nome,e.id]}
    @departamentos = Orgao.find_by_sigla("SEED").departamentos.order("nome asc").collect{|u|["#{u.sigla}",u.id]}
    @tipos = ["Orgão","Departamento","Escola"]
    @current_method = "new"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def departamentos
    @tipo = params[:tipo]
    if @tipo == "Orgao"
      @uos = Orgao.order("nome asc").collect{|u|[u.sigla,u.id]}
    elsif @tipo == "Departamento"
      @uos = Orgao.find_by_sigla("SEED").departamentos.order("nome asc").collect{|u|["#{u.sigla}",u.id]}
    elsif @tipo == "Escola"
      @uos = Escola.order("nome asc").collect{|u|[u.nome,u.id]}
    end
    render :update do |page|
      page.visual_effect :highlight,"departamentos"
      page.replace_html "departamentos", :partial=>"departamentos"
    end
  end
  # GET /users/1/edit
  def edit
    @user = Usuario.find(params[:id])
    @orgaos=Orgao.order(:sigla).collect{|o|[o.sigla,o.id]}
    @entidades = Entidade.all.collect{|e|[e.nome,e.id]}
    @tipo = @usuario.unidade_organizacional_type
    if @tipo and @tipo == "Orgao"
      @uos = Orgao.order("nome asc").collect{|u|[u.sigla,u.id]}
    elsif @tipo and @tipo == "Departamento"
      @uos = Orgao.find_by_sigla("SEED").departamentos.order("nome asc").collect{|u|["#{u.sigla}",u.id]}
    elsif @tipo and @tipo == "Escola"
      @uos = Escola.order("nome asc").collect{|u|[u.nome,u.id]}
    else
      @uos = Orgao.find_by_sigla("SEED").departamentos.order("nome asc").collect{|u|["#{u.sigla}",u.id]}
    end
    @tipos = [["Orgão","Orgao"],["Departamento"],["Escola"]]
    if !@user.orgao.nil?
      @orgao= Orgao.find(@user.orgao_id)
      @departamentos=@orgao.departamentos.order(:sigla).collect{|d|[d.sigla,d.id]}
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = Usuario.new(params[:usuario])
    @orgaos=Orgao.order(:sigla).collect{|o|[o.sigla,o.id]}
    respond_to do |format|
      if @user.save
        format.html { redirect_to(usuarios_url, :notice => 'Usuario criado com sucesso.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = Usuario.find(params[:id])
    @orgaos=Orgao.order(:sigla).collect{|o|[o.sigla,o.id]}
    @entidades = Entidade.all.collect{|e|[e.nome,e.id]}
    if params[:usuario][:password].blank?
      params[:usuario].delete(:password)
      params[:usuario].delete(:password_confirmation)
    end

    respond_to do |format|
      if @user.update_attributes!(params[:usuario])
        format.html { redirect_to(@user, :notice => "Usuario #{@user.username} atualizado com sucesso.") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = Usuario.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(usuarios_url) }
      format.xml  { head :ok }
    end
  end

  def grupos
    @roles = Role.order("name")
  end
end
