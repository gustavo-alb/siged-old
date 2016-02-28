# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  #load_and_authorize_resource
  skip_before_filter :authenticate_user!
  layout :layout_by_resource
  def index
    @disciplinas = Rails.cache.fetch('disciplinas', :expires_in => 24.hours) { DisciplinaContratacao.joins(:funcionarios).order('nome asc').uniq }
    # @disciplinas = DisciplinaContratacao.find(:all,:joins=>:funcionarios,:order=>['nome asc']).uniq
    @professores = Rails.cache.fetch('professores', :expires_in => 24.hours) { Funcionario.where(:cargo_id=>Cargo.find_by_nome("PROFESSOR")).uniq }
    # @professores = Funcionario.find_all_by_cargo_id(Cargo.find_by_nome("PROFESSOR")).uniq
    @indefinidos = Rails.cache.fetch('indefinidos', :expires_in => 24.hours) {Funcionario.where("cargo_id = ? and disciplina_contratacao_id is null",Cargo.find_by_nome("PROFESSOR")).uniq}
    # @indefinidos = Funcionario.find(:all,:conditions=>["cargo_id = ? and disciplina_contratacao_id is null",Cargo.find_by_nome("PROFESSOR")]).uniq
    # @i_lotados = Funcionario.find(:all,:joins=>:lotacoes,:conditions=>["lotacaos.ativo = ? and cargo_id = ? and disciplina_contratacao_id is null",true,Cargo.find_by_nome("PROFESSOR")]).uniq
    @i_lotados = Rails.cache.fetch('i_lotados', :expires_in => 24.hours) {Funcionario.joins(:lotacoes).where("cargo_id = ? and disciplina_contratacao_id is null and lotacaos.ativo = 'true'",Cargo.find_by_nome("PROFESSOR")).uniq}
    # @i_especificados = Funcionario.find(:all,:joins=>:especificacoes,:conditions=>["cargo_id = ? and disciplina_contratacao_id is null",Cargo.find_by_nome("PROFESSOR")]).uniq
    @i_especificados = Rails.cache.fetch('i_especificados', :expires_in => 24.hours) {Funcionario.joins(:especificacoes).where("cargo_id = ? and disciplina_contratacao_id is null",Cargo.find_by_nome("PROFESSOR")).uniq}
    @noticias = Mensagem.noticias.order(:created_at)
  end

  def home
  end

  def layout_by_resource
    if current_user.nil?
      "guest"
    else
      "application"
    end
  end
end
