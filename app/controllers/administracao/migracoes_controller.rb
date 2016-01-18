# -*- encoding : utf-8 -*-
class Administracao::MigracoesController < ApplicationController
  # GET /administracao/migracoes
  # GET /administracao/migracoes.xml
  def index

    @administracao_migracoes = Administracao::Migracao.all.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administracao_migracoes }
    end
  end

  # GET /administracao/migracoes/1
  # GET /administracao/migracoes/1.xml
  def show
    @administracao_migracao = Administracao::Migracao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administracao_migracao }
    end
  end

  # GET /administracao/migracoes/new
  # GET /administracao/migracoes/new.xml
  def new
    @administracao_migracao = Administracao::Migracao.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administracao_migracao }
    end
  end

  # GET /administracao/migracoes/1/edit
  def edit
    @administracao_migracao = Administracao::Migracao.find(params[:id])
  end

  # POST /administracao/migracoes
  # POST /administracao/migracoes.xml
  def create
    @administracao_migracao = Administracao::Migracao.new(params[:administracao_migracao])

    respond_to do |format|
      if @administracao_migracao.save
        format.html { redirect_to(@administracao_migracao, :notice => 'Migracao cadastrado com sucesso.') }
        format.xml  { render :xml => @administracao_migracao, :status => :created, :location => @administracao_migracao }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administracao_migracao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /administracao/migracoes/1
  # PUT /administracao/migracoes/1.xml
  def update
    @administracao_migracao = Administracao::Migracao.find(params[:id])

    respond_to do |format|
      if @administracao_migracao.update_attributes(params[:administracao_migracao])
        format.html { redirect_to(@administracao_migracao, :notice => 'Migracao atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administracao_migracao.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administracao/migracoes/1
  # DELETE /administracao/migracoes/1.xml
  def destroy
    @administracao_migracao = Administracao::Migracao.find(params[:id])
    @administracao_migracao.destroy

    respond_to do |format|
      format.html { redirect_to(administracao_migracoes_url) }
      format.xml  { head :ok }
    end
  end













  def salvar_arquivo
    @sucesso = 0
    @erros_count = 0
    @erros = ""
    @mensagem_erros = ""
    @mensagem=""
    @tipo_arquivo = params[:administracao_migracao][:arquivo]
    file_name=@tipo_arquivo.original_filename
    if @tipo_arquivo.content_type=="text/siged-migracao"
      pasta = File.join(Rails.root.to_s, 'public', 'arquivos','migracao')
      #  Dir.mkdir(pasta)

      if File.exist?(pasta)
        arquivo = File.join(pasta, file_name)
      elsif  !File.exist?(pasta)
        Dir.mkdir(pasta)
        arquivo = File.join(pasta, file_name)
      end

      @tipo_lista = TipoLista.find(params[:tipo_lista_id])
      if @tipo_lista.update_attributes(params[:tipo_lista])
        file = File.open(arquivo,'r')
        linhas = file.readlines
        @linha = linhas.first.gsub("\r","").gsub("\n","")
        @tamanho = @linha.size
        if @tamanho > 11
          @tipo_lista.arquivo.destroy
          redirect_to :back, :alert => "Este arquivo '#{@tipo_arquivo.original_filename}' não está no formato aceito pelo sistema! #{@linha}"
        else

          linhas.each do |l|
            cpf=l.gsub("\r","").gsub("\n","")
            pessoa = Pessoa.find_by_cpf(cpf)
            lista = @tipo_lista.listas.new
            if @tipo_lista.tipo_objeto =='Pessoa' and !pessoa.nil?
              lista.pessoa_id = pessoa.id

            end
            lista.motivo = params[:lista][:motivo]
            lista.data_inclusao = Time.now.to_date
            if lista.save
              @sucesso+=1
            else
              @erros_count+=1
              lista.errors.full_messages.each do |msg|
                if pessoa
                  @erros+="#{pessoa.nome} #{msg}<br/>"
                end
              end

            end
          end
          if @sucesso>0
            @mensagem+="#{@sucesso} #{@tipo_lista.tipo_objeto.pluralize} adicionadas à lista #{@tipo_lista.nome}\n"
          else
            @mensagem+="Nenhuma pessoa adicionada<br/>"
          end
          if @erros_count>0
            @mensagem_erros += " com #{@erros_count} erros, sendo eles:<br/>"
            @mensagem_erros += @erros
          end

          redirect_to  tipo_lista_listar_url(@tipo_lista), :flash => { :notice => @mensagem,:alert=>@mensagem_erros}


        end

        file.close

      end

    else
      redirect_to :back, :alert => "Este tipo de arquivo '#{@tipo_arquivo.content_type}' não é válido para esta ação. Favor inserir um arquivo de texto (*.txt)"
    end

  end
end
