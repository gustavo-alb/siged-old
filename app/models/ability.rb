# -*- encoding : utf-8 -*-

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.gerar_ponto?
      can :manage,Departamento
      cannot :update,Departamento
      cannot :create,Departamento
      cannot :destroy,Departamento
      can :manage,Ponto,:unidade_organizacional_id=>user.unidade_organizacional_id
      cannot :destroy,Ponto
    end

    if user.role? :admin
      can :manage, :all
      #if !user.roles.none?
      #  can :manage,TipoLista,:privada=>false
      #  cannot :destroy,TipoLista,:privada=>false
      #  can :manage,TipoLista,TipoLista.privadas do |l|
      #    !(l.role_ids & user.role_ids).none?
      #  end
    end


      if user.role? :chefia_ucada
        can :manage,Funcionario
        #cannot :destroy,Funcionario
        can :manage,Pessoa
        #cannot :destroy,Pessoa
        can :manage,Departamento
        cannot :update,Departamento
        cannot :create,Departamento
        cannot :destroy,Departamento
        can :read,Orgao
        can :agenda,Orgao
        can :read,Lotacao
        can :qualificar_funcionario, Pessoa
      end

      if user.role? :ucada
        can :manage,Funcionario
        cannot :destroy,Funcionario
        can :manage,Pessoa
        cannot :destroy,Pessoa
        cannot :destroy,TipoLista,:privada=>false
        can :manage,TipoLista
        cannot [:update,:destroy],TipoLista,TipoLista.privadas do |l|
          l.privada==true and (l.role_ids & user.role_ids).none?
        end
        can :qualificar_funcionario, Pessoa
      end

      if user.role? :ucada_alt
        can :manage,Funcionario
        can :manage,Pessoa
        cannot :destroy,TipoLista,:privada=>false
        can :manage,TipoLista
        cannot [:update,:destroy],TipoLista,TipoLista.privadas do |l|
          l.privada==true and (l.role_ids & user.role_ids).none?
        end
        can :qualificar_funcionario, Pessoa
      end

      if user.role? :diretores
        can :manage,Lotacao,:escola_id=>user.escola_id
        cannot :create,Lotacao
        can :manage,Turma,:escola_id=>user.escola_id
        can :manage,Ambiente,:escola_id=>user.escola_id
        can :manage,Escola,:id=>user.escola_id
        cannot :destroy,Escola
        cannot :destroy,Turma
        can :read,Pessoa
      #can :read,Requisicao,:lotacao_id=>user.unidade_organizacional_id,:lotacao_type=>user.unidade_organizacional_type
      can :manage,Requisicao,:lotacao_id=>user.unidade_organizacional_id,:lotacao_type=>user.unidade_organizacional_type
    end

    if user.role? :enquete
      can :read,Pessoa
      cannot :show,Pessoa
      can :read,Orgao
      can :agenda,Orgao
      can :read,Departamento
      can :read,Funcionario
      can :read,Lotacao
      can :manage,Enquete
    end

    if user.role? :sage
      can :read,Pessoa
      can :show,Pessoa
      can :read,Orgao
      can :agenda,Orgao
      can :manage,Departamento
      cannot :destroy,Departamento
      can :read,Funcionario
      can :read,Lotacao
      can :qualificar_funcionario, Pessoa
    end

    if user.role? :chefia_cad
      can :read,Pessoa
      can :read,Funcionario
      can :qualificar_funcionario, Pessoa
    end

    if user.role? :chefia_cebep
      can :manage,Pessoa
      cannot :update,Pessoa
      cannot :destroy,Pessoa
      can :manage,Funcionario
      cannot :update,Funcionario
      cannot :destroy,Pessoa
      can :qualificar_funcionario, Pessoa
    end

    if user.role? :cebep
      can :manage,Pessoa
      cannot :update,Pessoa
      cannot :destroy,Pessoa
      can :manage,Funcionario
      cannot :update,Funcionario
      cannot :destroy,Funcionario
      can :manage, Comissionado
      cannot :destroy,Comissionado
      can [:read,:update],Escola
    end

    if user.role? :chefia_nupes
      can :manage, Lotacao
      can :manage, Pessoa
      can :manage, Funcionario
      cannot :destroy, Pessoa
      cannot :edit, Pessoa
      cannot :destroy, Funcionario
      cannot :edit, Funcionario
      cannot :destroy, Lotacao
      can :qualificar_funcionario, Pessoa
    end

    if user.role? :nupes
      can :read,Pessoa
      can :read,Funcionario
    end

    if user.role? :chefia_upag
      can :read,Pessoa
      can :read,Funcionario
      can :manage,Folha
      can :manage,Folha::Folha
      can :manage,Folha::FonteRecurso
      can :manage,Folha::Financeiro
      can :manage,Folha::Competencia
      can :manage,Folha::Evento
      cannot :destroy,Folha::Folha
      cannot :destroy,Folha::FonteRecurso
      cannot :destroy,Folha::Competencia
      cannot :destroy,Folha::Evento
      can :manage,ReferenciaNivel
      cannot :destroy,ReferenciaNivel
      can :qualificar_funcionario, Pessoa
    end

    if user.role? :ponto
      can :manage,Departamento
      cannot :update,Departamento
      cannot :create,Departamento
      cannot :destroy,Departamento
      can :manage,Ponto
      cannot :destroy,Ponto
    end

    if user.role? :qualificacao
      can :qualificar_funcionario, Pessoa
    end

    if user.role? :relatorios
      can :emitir_relatorios, :all
    end

    if user.role? :upag
      can :read,Pessoa
      can :read,Funcionario
      can :manage,Folha
      can :manage,Folha::Folha
      can :manage,Folha::FonteRecurso
      can :manage,Folha::Financeiro
      can :manage,Folha::Competencia
      can :manage,Folha::Evento
      cannot :destroy,Folha::Folha
      cannot :destroy,Folha::FonteRecurso
      cannot :destroy,Folha::Competencia
      cannot :destroy,Folha::Evento
      can :manage,ReferenciaNivel
      cannot :destroy,ReferenciaNivel
    end

    if user.role? :lotacao
      can :manage, Lotacao
      cannot :convalidar,Lotacao
      can :read,Funcionario
      can :manage,Pessoa
      cannot :create,Pessoa
      cannot :edit,Pessoa
      cannot :destroy,Pessoa
      can :manage,Funcionario
      cannot :create,Funcionario
      cannot :destroy,Funcionario
      cannot :edit,Funcionario
      can :manage, AnoLetivo
      cannot :create, AnoLetivo
      can :gerir_carencias, Carencia
      can :autocomplete_departamento_nome,Departamento
      can :autocomplete_escola_nome,Escola
      can :manage, Escola
      can :inspecionar, Escola
      cannot [:create,:update,:destroy,:configuracoes],Escola
      cannot :especificar_lotacao,Lotacao
    end

    if user.role? :chefia_ucolom
      can :manage, Lotacao
      cannot :convalidar,Lotacao
      #cannot :create, Lotacao
      can :read,Funcionario
      can :manage,Pessoa
      cannot :create,Pessoa
      cannot :edit,Pessoa
      cannot :destroy,Pessoa
      can :manage,Funcionario
      cannot :create,Funcionario
      cannot :destroy,Funcionario
      cannot :edit,Funcionario
      cannot :update,Funcionario
      can :emitir_relatorios,[Lotacao,Pessoa,Funcionario,Escola]
      can :manage, Escola
      cannot [:create,:update,:destroy,:configuracoes],Escola
      cannot :especificar_lotacao,Lotacao
    end

    if user.role? :crh
      can :read,Pessoa
      can :adicionar_a_lista,Pessoa
      can :salvar_lista,Pessoa
      can :read,Funcionario
      can :manage,Formacao
      cannot :destroy,Formacao
      can :read,Orgao
      can :agenda,Orgao
      can :manage,TipoLista,:privada=>false
      cannot :remover_pessoa,TipoLista,:privada=>false
    end

    if user.role? :chefia_crh
      can :read,Pessoa
      can :read,Funcionario
      can :manage,Formacao
      cannot :destroy,Formacao
      can :read,Orgao
      can :agenda,Orgao
    end

    if user.role? :recad
      can :manage,Funcionario
      cannot :destroy,Funcionario
      can :manage,Pessoa
      cannot :destroy,Pessoa
      can :manage,Lotacao
    end

    if user.role? :revisao_carga_horaria
      can :manage,Funcionario
      cannot :destroy,Funcionario
      cannot :edit,Funcionario
      cannot :edit,Pessoa
      can :manage,Pessoa
      cannot :destroy,Pessoa
      can :manage,Lotacao
      cannot :destroy,Lotacao
      cannot :convalidar,Lotacao
    end

    if user.role? :codnope
      can :read,Escola
      can :manage, Escola
      cannot [:create,:update,:destroy,:configuracoes],Escola
      can :manage,Matriz
    end

  end
end
