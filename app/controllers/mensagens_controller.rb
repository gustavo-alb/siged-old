# -*- encoding : utf-8 -*-
class MensagensController < ApplicationController
  # GET /mensagens
  # GET /mensagens.xml
  before_filter :dados_essenciais
  def index
    @mensagens = Mensagem.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mensagens }
    end
  end

  # GET /mensagens/1
  # GET /mensagens/1.xml
  def show
    @mensagem = Mensagem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mensagem }
    end
  end

  def inbox
    @usuario = User.usuario_atual
    @mensagens = Mensagem.entrada(@usuario)
    render :layout=>'facebox'
  end

  # GET /mensagens/new
  # GET /mensagens/new.xml
  def new
    @mensagem = Mensagem.new
    @usuario = User.usuario_atual
    @mensagens = Mensagem.entrada(@usuario)
    render :layout=>'facebox'
  end

  # GET /mensagens/1/edit
  def edit
    @mensagem = Mensagem.find(params[:id])
  end

  # POST /mensagens
  # POST /mensagens.xml
  def create
    @mensagem = Mensagem.new(params[:mensagem])
    @usuario = User.usuario_atual
    @mensagens = Mensagem.entrada(@usuario)

    if @mensagem.save
      render :update do |page|
        page.visual_effect :highlight,"form"
        page.replace_html "form", :partial=>"inbox"
      end
    else
      redirect_to :back,:alert=>'Mensagem não pode ser enviada. Tente novamente.'
    end
  end


  # PUT /mensagens/1
  # PUT /mensagens/1.xml
  def update
    @mensagem = Mensagem.find(params[:id])

    respond_to do |format|
      if @mensagem.update_attributes(params[:mensagem])
        format.html { redirect_to(@mensagem, :notice => 'Mensagem atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mensagem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mensagens/1
  # DELETE /mensagens/1.xml
  def destroy
    @usuario = User.usuario_atual
    @mensagens = Mensagem.entrada(@usuario)
    @mensagem = Mensagem.find(params[:id])
    @mensagem.destroy
    render :update do |page|
      page.visual_effect :highlight,"inbox"
      page.replace_html "inbox", :partial=>"inbox"
    end
  end
end
