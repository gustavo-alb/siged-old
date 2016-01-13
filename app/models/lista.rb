# -*- encoding : utf-8 -*-
class Lista < ActiveRecord::Base

  self.table_name = "listas"
  belongs_to :tipo_lista,:class_name=>"TipoLista",:foreign_key=>"tipo_lista_id"
  belongs_to :pessoa
  belongs_to :entidade
  after_create :criar_processo
  validates_presence_of :pessoa_id,:message=>"Não pode ficar em branco"
  validates_uniqueness_of :pessoa_id,:scope=>[:data_inclusao,:tipo_lista_id],:allow_nil=>true,:message=>"já está na lista"
  validates_uniqueness_of :funcionario_id,:scope=>[:data_inclusao,:tipo_lista_id],:allow_nil=>true
  belongs_to :funcionario
  scope :da_pessoa, lambda {|id,tipo| where("pessoa_id=? and tipo_lista_id=?",id,tipo)}
  #scope :da_pessoa, lambda {|id| where("aipo_objeto=? and id not in (?)","Pessoa",ids)}
  after_create :criar_processo

  def remover_da_lista
    self.ativo=false
    self.save
    self.criar_processo('remover_da_lista')
  end

  private
  def criar_processo(tipo='incluir_na_lista')
    cod=Num.new
    processo=Processo.new
    processo.tipo="LISTA"
    if tipo=='incluir_na_lista'
      processo.natureza="Adicionar À Lista"
    else
      processo.natureza="Remover da Lista"
    end
    processo.pessoa_id=self.pessoa.id
    processo.destino_id=self.id
    processo.ano_processo=self.data_inclusao.year
    if processo.save!
      num=processo.id
      if tipo=='incluir_na_lista'
        processo.processo="AL#{cod.numero(num)}/#{self.data_inclusao.year}"
      else
        processo.processo="RL#{cod.numero(num)}/#{self.data_inclusao.year}"
      end
      status=Status.new
      status.data=Time.now
      status.processo_id=processo.id
      if tipo=='incluir_na_lista'
        status.status="ADICIONARALISTA"
      else
        status.status="REMOVERDALISTA"
      end
      status.save
      processo.save
    else
      processo.errors.add_to_base("O processo não pôde ser criado")
    end
  end
end
