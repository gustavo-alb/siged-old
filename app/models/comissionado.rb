# -*- encoding : utf-8 -*-
class Comissionado < ActiveRecord::Base
  scope :do_func, lambda {|id|where("funcionario_id = ?",id) }
  scope :exoneracoes, -> { where("ativo = ? and decreto_exoneracao is not null",false)}
  scope :ativos, -> { where("ativo = ? and decreto_exoneracao is null",true)}
  scope :busca, lambda { |q| where("funcionario_id like ? or funcionario_id like ?" ,"%#{q}%","%#{q}%") }
  scope :tipos, lambda{|t| where("tipo ilike ?",t)}
  belongs_to :orgao
  belongs_to :funcionario,:class_name=>'Funcionario'
  belongs_to :departamento
  belongs_to :escola
  has_one :user,:through=>:funcionario,:dependent=>:destroy
  has_many :pontos
  after_create :lotacao_comissionada,:usuario,:atual
  TIPOE=[
    ['Diretoria','DIRETORIA'],
    ['Diretoria Adjunta','DIRETORIA ADJUNTA'],
    ['Secretaria','SECRETARIA'],
    ['Supervisão','SUPERVISÃO']
  ]
  TIPOD=[
    ['Chefia','CHEFIA']
  ]

  def exonerar(data,decreto)
    self.update_attributes(:ativo=>false,:decreto_exoneracao=>decreto,:data_exoneracao=>data)
    self.usuario.update_attributes(:enabled=>false)
  end



  private
  def atual
    if !self.escola.nil?
      self.escola.comissionados.ativos.tipos(self.tipo).find(:all,:conditions=>["id <> ?",self.id]).each do |c|
        c.update_attributes(:ativo=>false)
      end
    end
  end

  def usuario
    if self.tipo=="DIRETORIA"
      User.create(:name=>self.funcionario.nome,:username=>self.funcionario.pessoa.cpf,:password=>self.funcionario.matricula.reverse,:password_confirmation=>self.funcionario.matricula.reverse,:enabled=>true,:email=>self.funcionario.pessoa.email,:orgao_id=>self.escola.orgao_id,:escola_id=>self.escola_id,:funcionario_id=>self.funcionario_id)
    end
  end

  def lotacao_comissionada
    self.funcionario.lotacoes.create(:tipo_lotacao=>"COMISSÃO",:departamento_id=>self.departamento_id,:escola_id=>self.escola_id,:orgao=>self.orgao,:esfera_id=>self.orgao.esfera,:entidade_id=>self.funcionario.entidade_id,:data_lotacao=>Date.today,:usuario=>User.usuario_atual)
  end

end
