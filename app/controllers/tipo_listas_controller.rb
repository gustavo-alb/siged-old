# -*- encoding : utf-8 -*-
class TipoListasController < ApplicationController
  # GET /tipo_lista
  # GET /tipo_lista.xml
  load_and_authorize_resource
  def index
    @search = TipoLista.scoped_search(params[:search])
    ids = (@search.where("privada = ? and id in (?)",true, User.usuario_atual.lista_ids).collect{|l|l.id} + @search.where("privada = ?",false).collect{|l|l.id}).uniq
    @tipo_lista = TipoLista.where('id in (?)',ids).order(:nome) #.paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tipo_lista }
    end
  end

  def adicionar_de_arquivo
    @tipo_lista = TipoLista.find(params[:tipo_lista_id])
  end

  def salvar_arquivo
    @sucesso = 0
    @erros_count = 0
    @erros = ""
    @mensagem_erros = ""
    @mensagem=""
    @tipo_arquivo = params[:tipo_lista][:arquivo]
    file_name=@tipo_arquivo.original_filename
    if @tipo_arquivo.content_type=="text/plain"
      pasta = File.join(Rails.root.to_s, 'public', 'arquivos')
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

  def relatorio
    @tipo_lista = TipoLista.find(params[:tipo_lista_id])
    @pessoas = @tipo_lista.pessoas.order(:nome)
    @funcionarios = Funcionario.find :all,:conditions=>["pessoa_id in (?)",@pessoas]
    relatorio = ODFReport::Report.new("#{Rails.root}/public/relatorios/listas.odt") do |r|
      r.add_table("FUNCIONARIOS", @funcionarios, :header=>true) do |t|
        t.add_column(:nome) {|f| "#{f.pessoa.nome}"}
        t.add_column(:mat) {|f| "#{f.matricula}"}
        t.add_column(:car) {|f| "#{cargo_disciplina(f)}"}
        t.add_column(:cpf) {|f| "#{Cpf.new(f.pessoa.cpf)}"}
        t.add_column(:quad) {|f| "#{f.entidade.sigla}"}
        t.add_column(:tel) {|f| "#{f.pessoa.telefone_celular}"}
        t.add_column(:lotacao) {|f| "#{dest(f.lotacoes.atual.last,f)}"}
      end
    end

    send_file(relatorio.generate)
  end



  def listar
    @tipo_lista = TipoLista.find(params[:tipo_lista_id])
    case @tipo_lista.tipo_objeto
    when 'Pessoa' then
      @pessoas = @tipo_lista.pessoas.all.paginate :page => params[:page], :order => 'nome DESC', :per_page => 20
    when 'Funcionário' then
    end
  end

  def remover_pessoa
    @tipo_lista = TipoLista.find(params[:id])
    @pessoa = @tipo_lista.pessoas.find(params[:pessoa_id])
    @lista = Lista.find :first,:conditions=>["pessoa_id=? and tipo_lista_id=?",@pessoa.id,@tipo_lista.id]
    if @lista.destroy
      @tipo_lista = TipoLista.find(params[:id])
      @pessoas = @tipo_lista.pessoas.all
      render(:update) { |page| page.reload }

    end
  end

  def detalhes_pessoa
    @tipo_lista = TipoLista.find(params[:tipo_lista_id])
    @pessoa = @tipo_lista.pessoas.find(params[:pessoa_id])
    @lista = Lista.find :first,:conditions=>["pessoa_id=? and tipo_lista_id=?",@pessoa.id,@tipo_lista.id]
    render :layout=>"facebox"
  end
  # GET /tipo_lista/1
  # GET /tipo_lista/1.xml
  def show
    @tipo_lista = TipoLista.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tipo_lista }
    end
  end

  # GET /tipo_lista/new
  # GET /tipo_lista/new.xml
  def new
    @tipo_lista = TipoLista.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tipo_lista }
    end
  end

  # GET /tipo_lista/1/edit
  def edit
    @tipo_lista = TipoLista.find(params[:id])
  end

  # POST /tipo_lista
  # POST /tipo_lista.xml
  def create
    @tipo_lista = TipoLista.new(params[:tipo_lista])

    respond_to do |format|
      if @tipo_lista.save
        format.html { redirect_to(@tipo_lista, :notice => 'Tipo lista cadastrado com sucesso.') }
        format.xml  { render :xml => @tipo_lista, :status => :created, :location => @tipo_lista }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tipo_lista.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tipo_lista/1
  # PUT /tipo_lista/1.xml
  def update
    @tipo_lista = TipoLista.find(params[:id])

    respond_to do |format|
      if @tipo_lista.update_attributes(params[:tipo_lista])
        format.html { redirect_to(tipo_lista_url(@tipo_lista), :notice => 'Tipo lista atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tipo_lista.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tipo_lista/1
  # DELETE /tipo_lista/1.xml
  def destroy
    @tipo_lista = TipoLista.find(params[:id])
    if @tipo_lista.possui_funcionarios?
      mensagem="a lista #{@tipo_lista.nome} possui funcionários, não pode ser removida"
    else
      @tipo_lista.destroy
      mensagem="O tipo #{@tipo_lista.nome} foi removida com sucesso!"
    end
    respond_to do |format|
      format.html { redirect_to(tipo_listas_url,:alert => mensagem) }
      format.xml  { head :ok }
    end
  end
end

private
def dest(lotacao,f)
  if lotacao
    if lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
      return "#{lotacao.departamento.sigla.upcase}/#{lotacao.orgao.sigla.upcase}"
    elsif lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.escola.nil?
      return "#{lotacao.escola.nome.upcase}/#{lotacao.orgao.sigla.upcase}"
    elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
      return "#{lotacao.departamento.nome.upcase}/#{lotacao.orgao.sigla.upcase}"
    elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL"  and !lotacao.escola.nil? and lotacao.departamento.nil?
      return "#{lotacao.escola.nome.upcase}/#{lotacao.orgao.sigla.upcase}"
    elsif lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
      return "#{lotacao.orgao.sigla.upcase}"
    elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
      return "#{lotacao.orgao.sigla.upcase}"
    else
      return "#{lotacao.escola.nome.upcase}"

    end
  elsif !f.lotacao_recad.blank?
    return "#{f.lotacao_recad.upcase}"
  else
    return "NADA CADASTRADO"
  end
end
