# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :set_entidade
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to :back, :alert => "Você não tem autorização para acessar esta área"
  end

  protect_from_forgery

  protected

  def set_entidade
    if user_signed_in?
      listas = []
      User.usuario_atual = current_user
      User.ultimo_ip = User.usuario_atual.current_sign_in_ip
      User.usuario_atual.save!
      User.usuario_atual.roles.each do |r|
        r.lista_ids.each do |l|
          listas << l
        end
      end
      User.lista_ids = listas
    end
  end


  private
  def dados_essenciais
    @destinos = TipoDestino.all.collect{|t|[t.nome,t.id]}
    @cargos = Cargo.order(:nome).collect{|c|[c.nome.upcase,c.id]}
    @orgaos = Orgao.order(:nome).collect{|o|[o.sigla.upcase,o.id]}
    @niveis_f = Nivel.order(:ordem).collect{|n|[n.nome.upcase,n.id]}
    @municipios = Municipio.order(:nome).collect{|m|[m.nome,m.id]}
    @sitjuridicas = SituacoesJuridica.order(:sigla).collect{|s|[s.nome,s.id]}
    @niveis = ReferenciaNivel.order(:codigo).collect{|n|["#{n.nome} - #{n.codigo} - #{n.jornada}H",n.id]}
    @esferas = Esfera.order(:nome).collect{|n|[n.nome,n.id]}
    @escolas = Escola.order(:nome).collect{|p| [p.nome,p.id]}
    @poderes = Poder.order(:nome).collect{|p|[p.nome,p.id]}
    @disciplinas = DisciplinaContratacao.order(:nome).collect{|p|[p.nome,p.id]}
    @quadros = Quadro.order(:nome).collect{|p|[p.nome,p.id]}
    # @folhas = Folha.all.collect{|p|[p.nome,p.id]}
    @tipos = Tipo.order(:nome).collect{|p|[p.nome,p.id]}
    @niveiscargos = NivelCargo.order(:nome).collect{|p|[p.nome,p.id]}
    #@diretores = Diretor.all.collect{|p|[p.pessoa.nome,p.id]}
    @tipo_ambientes = TipoAmbiente.all.collect{|t|[t.nome,t.id]}
    @series = Serie.all.collect{|s|[s.nome,s.id]}
    @categorias = Categoria.all.collect{|c|[c.nome,c.id]}
    @categorias_contrato = Categoria.where("nome ilike ?","%contrato%").collect{|c|[c.nome,c.id]}
    @entidades = Entidade.all.collect{|e|[e.nome,e.id]}
    @recursos = Folha::FonteRecurso.all.collect{|r|[r.nome,r.id]}
    @usuarios = User.order(:username).collect{|u|["#{u.name} (#{u.username})",u.id]}
    @noticias = Mensagem.noticias.order(:created_at)
    @anos_letivos = AnoLetivo.order(:ano).collect{|a|[a.ano,a.id]}
    @naturezas = ["Sala de Aula","Complementar Carga Horária","Coordenação Pedagógica","Direção","Secretaria Escolar","Biblioteca","Sala de Leitura","Coordenador do Mais Educação","Projeto","Sala de Leitura"]
    # ,"Retorno de Licença Prêmio","Retorno de Licença Maternidade","Retorno de Licença Sem Vencimento","Exoneração","Aposentadoria"
  end
end
