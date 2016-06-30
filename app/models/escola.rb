# -*- encoding : utf-8 -*-
#include Serenity::Generator
class Escola < ActiveRecord::Base
  extend FriendlyId
  friendly_id :nome, :use=> :slugged
  validates_presence_of :codigo,:nome,:message=>" Não pode ficar em branco!"
  validates_uniqueness_of :nome, :message=>"Já cadastrado",:scope => [:codigo,:nome_da_escola ],:case_sensitive=>false

  has_many :turmas,:through=>:ano_letivo
  has_many :salas_ambiente,:class_name=>"Ambiente.salas_ambientes"
  has_many :settings
  has_many :ambientes,:dependent=>:destroy
  has_many :funcionarios,:through=>:lotacoes
  has_many :cargos,:through=>:funcionarios
  has_many :categorias,:through=>:funcionarios
  has_many :comissionados
  has_many :lotacoes,:class_name=>"Lotacao",:dependent=>:destroy,:as=>:destino
  has_many :especificacoes,:class_name=>'EspecificarLotacao',:dependent=>:destroy
  has_one :diretor_adjunto
  has_one :diretor
  has_one :secretario
  has_one :supervisor
  belongs_to :tipo_destino
  belongs_to :municipio
  belongs_to :esfera
  belongs_to :orgao
  belongs_to :ano_letivo,:class_name=>"AnoLetivo"
  belongs_to :entidade
  has_and_belongs_to_many :niveis,:class_name=>'NiveisEnsino',:join_table=>"escolas_matrizes"



  after_create :criar_ambientes

  def self.find_or_create(attributes)
    Escola.where(attributes).first || Escola.create(attributes)
  end
  #scoped_search

  scope :busca, lambda { |q| where("codigo ilike ? or nome_da_escola ilike ?" ,"%#{q}%","%#{q}%") }
  scope :municipal, -> {  where("rede ilike ?","municipal")}
  scope :efetivos,  -> { joins(:funcionarios).where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Ex-Ipesap"), Categoria.find_by_nome("Estado Antigo"), Categoria.find_by_nome("Estado Novo")])}
  scope :federais,  -> { joins(:funcionarios).where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Ex-Território do Amapá"), Categoria.find_by_nome("Ex-Território Federal do Amapá - Comissionado"), Categoria.find_by_nome("Ministério da Educação"), Categoria.find_by_nome("Ministério da Educação - Comissionado")])}
  scope :contratos,  -> { joins(:funcionarios).where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Contrato Administrativo")])}
  scope :em_comissao,  -> { joins(:funcionarios).where("funcionarios.categoria_id in (?)",[Categoria.find_by_nome("Sem Vínculo"), Categoria.find_by_nome("Ex-Território Federal do Amapá - Comissionado"), Categoria.find_by_nome("Ministério da Educação - Comissionado")])}
  scope :estadual,  -> { where("rede ilike ?","estadual")}

  scope :lotacoes_ativas,  -> { joins(:lotacoes).where("lotacaos.ativo = 'true'")}
  # scope :com_turma, -> {joins(:turma).where("turmas.nome is not null")}
  # .where("lotacoes.ativo = true")
  # scope :do_integral, -> {joins(:turma).where("turmas.turno = 4")}

  ZONA=[["Urbana","Urbana"],["Rural","Rural"]]


  def calcular_demanda(disc,niv=nil)
    demanda = 0
    if niv.nil?
      turmas = self.turmas
    else
      turmas = self.turmas.do_nivel(niv)
    end
    if !turmas.none?
      turmas.all.each do |t|
        t.curriculos.da_serie(t.serie.id).da_disciplina(disc).uniq.each do |c|
          demanda+=c.horas_semanal.to_i
        end
      end
      return demanda
    end
  end

  def calcular_oferta(disc)
    professores = self.funcionarios.find_all_by_cargo_id(Cargo.find_by_nome('Professor'))
    oferta = 0
    profs = []
    disc.disciplinas_contratacao.each do |d|
      d.funcionarios.where('id in (?)',professores).each do |f|
        profs << f
      end
    end
    professores = profs.uniq
    professores.each do |p|
      oferta+=p.rsd
    end
    return oferta.to_i
  end

  def calcular_preenchido(disc)
    preenchido = 0
    self.especificacoes.da_disciplina(disc).uniq.each do |e|
      preenchido+=e.hora_semanal.to_i
    end
    return preenchido
  end

  def calcular_a_preencher(disc)
    preenchido = 0
    self.especificacoes.da_disciplina(disc).uniq.each do |e|
      preenchido+=e.hora_semanal.to_i
    end
    return self.calcular_demanda(disc) - preenchido
  end

  def calcular_excedente(disc)
    excedente = self.calcular_oferta(disc) - self.calcular_a_preencher(disc)
    if excedente <=0
      return 0
    else
      return excedente
    end
  end


  def disciplinas
    matrizes = self.matrizes
    disciplinas = []
    matrizes.each do |m|
      m.disciplinas.order(:nome).each do |d|
        disciplinas << d
      end
    end
    disciplinas = disciplinas.uniq
    return disciplinas
  end

  def matrizes
    matrizes = []
    self.niveis.each do |n|
      n.matrizes.each do |m|
        matrizes << m
      end
    end
    matrizes
  end

  def municipio_nome
    if self.municipio
      return self.municipio.nome.upcase
    end
  end



  def criar_ambientes
    self.ambientes.create(:nome=>"Secretaria Escolar",:tipo_ambiente=>TipoAmbiente.find_by_nome("Sala Ambiente"))
    self.ambientes.create(:nome=>"Biblioteca",:tipo_ambiente=>TipoAmbiente.find_by_nome("Sala Ambiente"))
    self.ambientes.create(:nome=>"Serviço Técnico-Pedagógico",:tipo_ambiente=>TipoAmbiente.find_by_nome("Sala Ambiente"))
    self.ambientes.create(:nome=>"Sala de Aula",:tipo_ambiente=>TipoAmbiente.find_by_nome("Sala de Aula"))
    self.ambientes.create(:nome=>"Diretoria",:tipo_ambiente=>TipoAmbiente.find_by_nome("Sala Ambiente"))
  end
end
