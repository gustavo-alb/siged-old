# -*- encoding : utf-8 -*-
class Matriz < ActiveRecord::Base
  has_many :curriculos,:foreign_key=>:matriz_id,:dependent=>:destroy
  has_many :disciplinas,:through=>:curriculos
  belongs_to :nivel,:class_name=>"NiveisEnsino",:foreign_key=>:nivel_id
  has_and_belongs_to_many :escolas,:join_table=>'escolas_matrizes'
  belongs_to :entidade
  has_many :turmas,:dependent=>:destroy
  has_and_belongs_to_many :series,:class_name=>"Serie",:join_table => "colapso_matrizes",:foreign_key=>:matriz_id
  validates_numericality_of :dias_letivos_anuais,:dias_letivos_semanais,:semanas_letivas,:carga_horaria_anual,:modulo_aula
  validates_presence_of :nivel_id

  after_create :criar_curriculo
  after_update :editar_curriculo



  def criar_curriculo
    self.series.each do |s|
      s.disciplinas.uniq.each do |d|
        c = self.curriculos.create(:serie_id=>s.id,:disciplina_id=>d.id)
      end
    end
  end


  def editar_curriculo
    curriculos = self.curriculos.find :all,:conditions=>["serie_id not in (?)",self.serie_ids]
    curriculos.each(&:destroy)
    self.series.each do |s|
      s.disciplinas.uniq.each do |d|
        if self.curriculos.find(:first,:conditions=>["serie_id = ? and disciplina_id = ?",s.id,d.id]).nil?
          c = self.curriculos.create(:serie_id=>s.id,:disciplina_id=>d.id)
        end
      end
    end
  end


  def remover_settings
    self.settings.delete_all
  end

end
