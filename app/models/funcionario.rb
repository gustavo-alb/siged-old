# -*- encoding : utf-8 -*-
class Funcionario < ActiveRecord::Base
  extend FriendlyId
  friendly_id :matricula, :use=> :slugged
    #include ApplicationHelper
    #include PessoasHelper
  #default_scope joins(:pessoa).order('pessoas.nome asc')
  #default_scope where('funcionarios.entidade_id in (?)',User.usuario_atual.entidade_ids)
  validates_presence_of  :cargo_id,:categoria_id,:nivel_id,:entidade_id,:data_nomeacao,:message=>"Não pode ficar em branco!"
  validates_presence_of :disciplina_contratacao_id,:if=>Proc.new{|f|f.cargo and f.cargo.nome=="Professor"}
  validates_presence_of :municipio_id,:if=>Proc.new{|f|[Categoria.find_by_nome("Concurso de 2012").id,Categoria.find_by_nome("Estado Novo").id,Categoria.find_by_nome("Contrato Administrativo").id].include?(f.categoria.id) if f.categoria}
  validates_uniqueness_of :matricula,:message=>"já existente",:on=>:create,:if => Proc.new {|f| not f.matricula.blank?}
  #audited :associated_with => :pessoa
  #has_associated_audits
  #scoped_search
  scope :busca, lambda { |q| where("matricula like ?" ,"%#{q}%") }
  scope :da_pessoa, lambda {|id|where("pessoa_id = ?",id) }
  scope :diretores, lambda { |q| where("diretor = ?" , true) }
  scope :disciplina_def, -> {  where("disciplina_contratacao_id is not ?",nil)}
  scope :sem_categoria,  -> { where("categoria_id is ?",nil)}
  scope :sem_lotacao,  -> { includes(:lotacoes).where(:lotacaos => { :funcionario_id => nil })}
  scope :da_escola,lambda {|id|joins(:lotacoes).where("lotacaos.escola_id = ?",id) }
  scope :ativos, -> { where(:ativo=>true)}



  scope :efetivos,  -> { where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Ex-Ipesap"), Categoria.find_by_nome("Estado Antigo"), Categoria.find_by_nome("Estado Novo"),Categoria.find_by_nome("Concurso de 2012"),Categoria.find_by_nome("992")])}
  scope :federais,  -> { where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Ex-Território do Amapá"), Categoria.find_by_nome("Ex-Território Federal do Amapá - Comissionado"), Categoria.find_by_nome("Ministério da Educação"), Categoria.find_by_nome("Ministério da Educação - Comissionado")])}
  scope :contratos,  -> { where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Contrato Administrativo")])}
  scope :em_comissao,  -> { where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Sem Vínculo"), Categoria.find_by_nome("Ex-Território Federal do Amapá - Comissionado"), Categoria.find_by_nome("Ministério da Educação - Comissionado")])}


  #has_and_belongs_to_many :grupos_educacionais,:class_name=>"GrupoEducacional",:join_table=>:colapso_grupo
  has_many :gratificacoes
  belongs_to :pessoa,:class_name=>'Pessoa'
  belongs_to :quadro
  belongs_to :cargo
  belongs_to :folha,:class_name=>"Folha::Folha"
  belongs_to :orgao
  belongs_to :municipio
  belongs_to :distrito
  belongs_to :processo
  belongs_to :entidade
  has_many :requisicoes
  has_one :user,:dependent=>:destroy
  belongs_to :fonte_recurso,:class_name=>"Folha::FonteRecurso"
  has_many :listas,:dependent=>:destroy
  has_many :pontos,:dependent=>:destroy
  #has_many :ponto_diarios
  has_many :funcoes_comissionadas,:class_name=>"Processo",:dependent=>:destroy
  has_many :pontos_do_mes,:class_name=>"Ponto"
  belongs_to :disciplina_contratacao
  has_many :comissionados,:dependent=>:destroy
  belongs_to :gaveta,:class_name=>"Arquivo"
  belongs_to :nivel, :class_name=>'ReferenciaNivel'
  belongs_to :sjuridica,:class_name=>'SituacoesJuridica'
  belongs_to :categoria
  has_many :lotacoes,:class_name=>"Lotacao",:dependent=>:destroy
  has_many :lotacoes_atuais,:class_name=>"Lotacao"
  has_many :processos,:dependent=>:destroy
  has_many :boletins, :class_name=>"BoletimFuncional",:dependent=>:nullify
  has_many :especificacoes,:class_name=>"EspecificarLotacao",:dependent => :destroy
  has_one :contrato
  accepts_nested_attributes_for :lotacoes
  scope :direcao,  -> { joins(:comissionados).where("comissionados.ativo=? and comissionados.tipo=?",true,'DIRETORIA')}
  after_create :criar_comissionado
  #attr_accessor(:rsn) {self.regencia_semanal_nominal}
  #attr_accessor(:rsd) {self.regencia_semanal_disponivel}
  attr_accessor(:disciplina) {self.disciplina_nome}

  def rsn
    return self.regencia_semanal_nominal
  end

  def rsd
    return self.regencia_semanal_disponivel
  end





  def aposentadoria
    self.data_nomeacao.months_since(300)
  end

  def quinquenio
    self.data_nomeacao.months_since(60)
  end

  def quadrop
    if self.categoria.nome.downcase=="Contrato Administrativo".downcase
      return "Quadro Temporário do Estado - Contrato Administrativo"
    elsif self.categoria.nome.downcase=="UDE".downcase
      return "Quadro Temporário do Estado - UDE"
    elsif self.categoria.nome.downcase=="Sem Vínculo".downcase
      return "Cargo Comissionado"
    else
      return "Quadro Efetivo do Estado"
    end
  end

  JORNADA=[["20 horas","20"],["40 horas","40"]]
  BANCO=[
    ['Banco do Brasil S.A.','Banco do Brasil S.A.'],
    ['Banco ABC Brasil S.A.','Banco ABC Brasil S.A.'],
    ['Banco Alfa S.A.','Banco Alfa S.A.'],
    ['Banco Alvorada S.A.','Banco Alvorada S.A.'],
    ['Banco Banerj S.A.','Banco Banerj S.A.'],
    ['Banco Bankpar S.A.','Banco Bankpar S.A.'],
    ['Banco Barclays S.A.','Banco Barclays S.A.'],
    ['Banco BBM S.A.','Banco BBM S.A.'],
    ['Banco Beg S.A.','Banco Beg S.A.'],
    ['Banco BGN S.A.','Banco BGN S.A.'],
    ['Banco BMG S.A.','Banco BMG S.A.'],
    ['Banco BNP Paribas Brasil S.A.','Banco BNP Paribas Brasil S.A.'],
    ['Banco Bonsucesso S.A.','Banco Bonsucesso S.A.'],
    ['Banco Bracce S.A.','Banco Bracce S.A.'],
    ['Banco Bradesco BBI S.A.','Banco Bradesco BBI S.A.'],
    ['Banco Bradesco Cartões S.A.','Banco Bradesco Cartões S.A.'],
    ['Banco Bradesco S.A.','Banco Bradesco S.A.'],
    ['Banco Brascan S.A.','Banco Brascan S.A.'],
    ['Banco BTG Pactual S.A.','Banco BTG Pactual S.A.'],
    ['Banco BVA S.A.','Banco BVA S.A.'],
    ['Banco Cacique S.A.','Banco Cacique S.A.'],
    ['Banco Caixa Geral - Brasil S.A.','Banco Caixa Geral - Brasil S.A.'],
    ['Banco Cargill S.A.','Banco Cargill S.A.'],
    ['Banco Citibank S.A.','Banco Citibank S.A.'],
    ['Banco Citicard S.A.','Banco Citicard S.A.'],
    ['Banco CNH Capital S.A.','Banco CNH Capital S.A.'],
    ['Banco Cooperativo Sicredi S.A.','Banco Cooperativo Sicredi S.A.'],
    ['Banco Credit Agricole Brasil S.A.','Banco Credit Agricole Brasil S.A.'],
    ['Banco Credit Suisse (Brasil) S.A.','Banco Credit Suisse (Brasil) S.A.'],
    ['Banco Cruzeiro do Sul S.A.','Banco Cruzeiro do Sul S.A.'],
    ['Banco da Amazônia S.A.','Banco da Amazônia S.A.'],
    ['Banco Daycoval S.A.','Banco Daycoval S.A.'],
    ['Banco de Lage Landen Brasil S.A.','Banco de Lage Landen Brasil S.A.'],
    ['Banco de Pernambuco S.A. - BANDEPE','Banco de Pernambuco S.A. - BANDEPE'],
    ['Banco Dibens S.A.','Banco Dibens S.A.'],
    ['Banco do Estado de Sergipe S.A.','Banco do Estado de Sergipe S.A.'],
    ['Banco do Estado do Pará S.A.','Banco do Estado do Pará S.A.'],
    ['Banco do Nordeste do Brasil S.A.','Banco do Nordeste do Brasil S.A.'],
    ['Banco Fator S.A.','Banco Fator S.A.'],
    ['Banco Fiat S.A.','Banco Fiat S.A.'],
    ['Banco Fibra S.A.','Banco Fibra S.A.'],
    ['Banco Ficsa S.A.','Banco Ficsa S.A.'],
    ['Banco Ford S.A.','Banco Ford S.A.'],
    ['Banco GE Capital S.A.','Banco GE Capital S.A.'],
    ['Banco GMAC S.A.','Banco GMAC S.A.'],
    ['Banco Guanabara S.A.','Banco Guanabara S.A.'],
    ['Banco Honda S.A.','Banco Honda S.A.'],
    ['Banco Ibi S.A. Banco Múltiplo','Banco Ibi S.A. Banco Múltiplo'],
    ['Banco IBM S.A.','Banco IBM S.A.'],
    ['Banco Industrial do Brasil S.A.','Banco Industrial do Brasil S.A.'],
    ['Banco Industrial e Comercial S.A.','Banco Industrial e Comercial S.A.'],
    ['Banco Indusval S.A.','Banco Indusval S.A.'],
    ['Banco Investcred Unibanco S.A.','Banco Investcred Unibanco S.A.'],
    ['Banco Itaú BBA S.A.','Banco Itaú BBA S.A.'],
    ['Banco ItaúBank S.A','Banco ItaúBank S.A'],
    ['Banco Itaucred Financiamentos S.A.','Banco Itaucred Financiamentos S.A.'],
    ['Banco J. P. Morgan S.A.','Banco J. P. Morgan S.A.'],
    ['Banco J. Safra S.A.','Banco J. Safra S.A.'],
    ['Banco John Deere S.A.','Banco John Deere S.A.'],
    ['Banco Luso Brasileiro S.A.','Banco Luso Brasileiro S.A.'],
    ['Banco Mercantil do Brasil S.A.','Banco Mercantil do Brasil S.A.'],
    ['Banco Modal S.A.','Banco Modal S.A.'],
    ['Banco Opportunity S.A.','Banco Opportunity S.A.'],
    ['Banco Panamericano S.A.','Banco Panamericano S.A.'],
    ['Banco Paulista S.A.','Banco Paulista S.A.'],
    ['Banco Pine S.A.','Banco Pine S.A.'],
    ['Banco Prosper S.A.','Banco Prosper S.A.'],
    ['Banco Toyota do Brasil S.A.','Banco Toyota do Brasil S.A.'],
    ['Banco Triângulo S.A.','Banco Triângulo S.A.'],
    ['Banco Volkswagen S.A.','Banco Volkswagen S.A.'],
    ['Banco Volvo (Brasil) S.A.','Banco Volvo (Brasil) S.A.'],
    ['Banco Votorantim S.A.','Banco Votorantim S.A.'],
    ['Banco VR S.A.','Banco VR S.A.'],
    ['Banco WestLB do Brasil S.A.','Banco WestLB do Brasil S.A.'],
    ['BPN Brasil Banco Múltiplo S.A.','BPN Brasil Banco Múltiplo S.A.'],
    ['BRB - Banco de Brasília S.A.','BRB - Banco de Brasília S.A.'],
    ['Caixa Econômica Federal','Caixa Econômica Federal'],
    ['Citibank N.A.','Citibank N.A.'],

  ]

  FOLHA=[
    ["Estado-Fundeb"],
    ["Estado-Não Fundeb"],
    ["Federal-Fundeb"],
    ["Federal-não Fundeb"],
    ["Sem Vinculo-Fundeb"],
    ["Sem Vinculo-Não Fundeb"]
  ]

  TIPOCOMISSAO=[
    ['Diretoria','DIRETORIA'],
    ['Diretoria Ad.','DIRETORIA ADJUNTA'],
    ['Secretaria','SECRETARIA'],
    ['Chefia','CHEFIA'],
    ['Assessor Técnico Nivel I','ASSESSOR TECNICO NIVEL I'],
    ['Assessor Técnico Nivel II','ASSESSOR TÉCNICO NIVEL II'],
    ['Responsável pela Atividade Nivel I','RESPONSÁVEL PELA ATIVIDADE NIVEL I']
  ]

  def regencia_semanal_nominal
    carga = self.nivel.jornada.to_i if self.nivel
    case carga
    when 20 then rsn=12
    when 40 then rsn=24
    when nil then rsn=24
    end
    return rsn
  end

  def disciplina_nome
    if !self.disciplina_contratacao.nil? and !self.nivel.nil? and self.cargo.nome=="PROFESSOR"
      return "PROFESSOR DE #{self.disciplina_contratacao.nome.upcase},#{self.nivel.nome.upcase}"
    elsif self.disciplina_contratacao.nil? and !self.nivel.nil? and self.cargo.nome=="PROFESSOR"
      return "PROFESSOR,#{self.nivel.nome.upcase}"
    else
      return "#{cargo.nome.upcase},#{self.nivel.nome.upcase}"
    end
  end


  def regencia_semanal_disponivel
    horas = 0
    self.especificacoes.all.each do |e|
      if e.turma.nil? and !e.ambiente.nil?
        horas+=self.rsn
      elsif !e.turma.nil?
        horas+=e.hora_semanal
      end
    end
    return self.rsn-horas
  end

  def turmas(escola,nivel=nil)
    turmas = []
    ambiente = escola.ambientes.find_by_nome("Sala de Aula")
    if escola and nivel.nil?
      self.especificacoes.da_escola(escola).do_ambiente(ambiente).each do |e|
        turmas << e.turma
      end
    elsif escola and !nivel.nil?
      self.especificacoes.da_escola(escola).do_ambiente(ambiente).each do |e|
        if e.turma.serie.nivel==nivel
          turmas << e.turma
        end
      end
    end
    return turmas.collect{|t|[t.nome]}.to_sentence
  end

  def regencia_especificada(tipo=1)
    horas=0
    if tipo==1
      self.especificacoes.find(:all,:joins=>:ambiente,:conditions=>["ambientes.nome = ?","Sala de Aula"]).each do |e|
        horas+=e.hora_semanal
      end
    elsif tipo==2
      self.especificacoes.find(:all,:joins=>:ambiente,:conditions=>["ambientes.nome <> ?","Sala de Aula"]).each do |e|
        horas+=e.hora_semanal
      end
    end
    return horas
  end


  def especificar_lotacao(escola = nil,turma = nil,disciplina = nil,curriculo = nil,lotacao = nil,tipo = nil,ambiente = nil)
    l = self.especificacoes.new
    l.escola_id=escola.id
    l.lotacao_id=lotacao.id
    if tipo=="Sala de Aula"
      fator = disciplina.fator(turma)
      l.turma_id=turma.id
      l.disciplina_id=disciplina.id
      #  if fator <= self.rsd
      #   l.hora_semanal = fator
      # elsif fator == self.rsd
      #   l.hora_semanal = self.rsd
      # end
      l.hora_semanal = fator
      if l.save
        disciplina.gerar_fator(turma,l.hora_semanal,turma.serie,curriculo,l)
        return true
      else
        return false
      end
    elsif tipo=="Sala Ambiente"
      l.ambiente_id = ambiente.id
      if l.save!
        return true
      else
        return false
      end
    end
  end


  def status_lotacao
    if !self.lotacoes.none?
      if !self.lotacoes.atual.none?
        if self.lotacoes.atual.last.status.last.status=="ENCAMINHADO"
          return "EM TRÂNSITO"
        elsif self.lotacoes.atual.last.status.last.status=="À DISPOSIÇÃO DO NUPES"
          return "À DISPOSIÇÃO DO NUPES"
        elsif self.lotacoes.atual.last.status.last.status=="CANCELADO"
          return "À DISPOSIÇÃO DO NUPES"
        elsif self.lotacoes.atual.last.status.last.status=="LOTADO"
          return "LOTADO"
        end
      else
        return "À DISPOSIÇÃO DO NUPES"
      end
    end
    else
      return "NÃO LOTADO"
    end

    def ids_disciplinas
      disciplinas=[]
      if !self.disciplina_contratacao.nil?
        disc = self.disciplina_contratacao.disciplinas
        disc.each do |d|
          disciplinas.push d.id
        end
        return disciplinas
      end
    end

    def flotacao
      lotacao(self)
    end

    private
    def criar_comissionado
      processo = self.funcoes_comissionadas.new
      processo.tipo = "COMISSÃO"
      if self.cargo_em_comissao.to_s=="true"
        if self.tipo_comissao=="DIRETORIA"
          processo.natureza="COMISSÃO/DIRETORIA"
          if self.tipo_comissao=="DIRETORIA ADJUNTA"
            processo.natureza="COMISSÃO/DIRETORIA"
          elsif self.tipo_comissao=="SECRETARIA"
            processo.natureza="COMISSÃO/SECRETARIA"
          elsif self.tipo_comissao=="CHEFIA"
            processo.natureza="COMISSÃO/CHEFIA"
            self.comissao_ativa=true
            self.save!
          end
          processo.funcionario_id=self.id
          processo.ano_processo=self.data_decreto_nomeacao.year
          processo.encaminhado_em=self.data_decreto_nomeacao
          processo.data_decreto_nomeacao=self.data_decreto_nomeacao
          processo.decreto_nomeacao=self.decreto_nomeacao
          if processo.save!
            num=processo.id
            cod=Num.new
            if self.tipo_comissao=="DIRETORIA"
              processo.processo="CD#{cod.numero(num)}/#{self.data_decreto_nomeacao.year}"
            elsif self.tipo_comissao=="SECRETARIA"
              processo.processo="CS#{cod.numero(num)}/#{self.data_decreto_nomeacao.year}"
            elsif self.tipo_comissao=="CHEFIA"
              processo.processo="CC#{cod.numero(num)}/#{self.data_decreto_nomeacao.year}"
            elsif self.tipo_comissao=="DIRETORIA ADJUNTA"
              processo.processo="CA#{cod.numero(num)}/#{self.data_decreto_nomeacao.year}"
            end
            processo.save!
          end
        end
      end
    end






  end
