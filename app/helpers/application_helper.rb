# -*- encoding : utf-8 -*-
module ApplicationHelper

  def primeiro_ultimo_nome(pessoa)
    @nome = pessoa.nome.split
    primeiro_nome = @nome.first
    ultimo_nome = @nome.last
    return "#{primeiro_nome.capitalize} #{ultimo_nome.capitalize}"
  end

  def disciplina(func)
    if func.disciplina_contratacao
      return func.disciplina_contratacao.nome
    else
      return "Nada Cadastrado"
    end
  end


  def booleano(obj)
    if obj==true
      return "Verificado"
    elsif obj==false or obj==nil
      return "Não Verificado"
    end
  end

  def municipio_lotacao(lot)
    if lot.destino and lot.destino_type=="Escola" and lot.destino.municipio
      return lot.destino.municipio.nome
    else
      return "Nada Cadastrado"
    end
  end

  def pdf_image_tag(image, options = {})
    caminho="../../../"+image
    options[:src] = File.expand_path(RAILS_ROOT) + '/public/images' + image
    tag(:img, options)
    return caminho
  end

  def int_em_dias(data1)
    data = (Date.today - data1).to_i
    if data!=0
      return "#{data} dias"
    else
      return "hoje"
    end
  end


  def setor
    user = current_user
    if user.unidade_organizacional and user.gerar_ponto?
      html = "<li>#{link_to 'Funcionários do Setor', funcionarios_pontos_path(:objeto_id=>user.unidade_organizacional_id,:tipo=>user.unidade_organizacional_type.downcase)}</li>"
    elsif user.unidade_organizacional.nil?
      ''
    end
    return raw(html)
  end



  def orgao
    user = User.usuario_atual
    if user.role?(:diretores) and !user.escola.nil?
      html = "<li class='icn_descri'>#{link_to user.escola.nome, escola_path(user.escola)}</li>"
    elsif !user.role?(:diretores) and !user.orgao.nil? and can? :manage,Ponto
      html = "<li class='icn_descri'>#{link_to user.orgao.sigla, orgao_path(user.orgao)}</li>"
    else
      html = ''
    end
    return raw(html)
  end

  def log(obj)
    if obj and !obj.usuario.blank?
      return raw("<b>#{obj.usuario.upcase}</b>")
    else
      return raw("Nada Cadastrado")
    end
  end


  def s_listas(p)
    if p.listas.size>0
      return p.listas.collect{|c|c.tipo_lista.nome}.to_sentence
    else
      return "Não está incluso em nenhuma lista"
    end
  end

  def porcentagem_funcional
    html=""
    html+="<div class='spacer'></div>"
    html+="<article class='module width_quarter'>"
    html+="<div class='overview_today'>"
    html+="<p class='overview_day'>Estatísticas</p>"
    html+="<p class='overview_count'>#{Funcionario.disciplina_def.count}</p>"
    html+="<p class='overview_type'>Disciplinas de contratação especificadas</p>"
    html+="<p class='overview_count'>#{Lotacao.regular.ativo.count}</p>"
    html+="<p class='overview_type'>Lotações Regulares</p>"
    html+="<p class='overview_count'>#{Lotacao.especial.ativo.count}</p>"
    html+="<p class='overview_type'>Lotações Especiais</p>"
    html+="<p class='overview_count'>#{Lotacao.sumaria.ativo.count}</p>"
    html+="<p class='overview_type'>Lotações Sumárias</p>"
    html+="<p class='overview_count'>#{Lotacao.sumaria_especial.ativo.count}</p>"
    html+="<p class='overview_type'>Lotações Sumárias Especiais</p>"
    html+="<p class='overview_count'>#{Lotacao.pro_labore.ativo.count}</p>"
    html+="<p class='overview_type'>Lotações Pro Labore</p> </article></div>"

    return raw(html)

  end

  def mensagens
    message = ""
    if notice
      message+="<h4 class='alert_success'>#{notice}</h4>"
    elsif alert
      message+="<h4 class='alert_error'>#{alert}</h4>"
    end
    raw(message)
  end


  def mensagens_login
    message = ""
    if notice
      message+="<h4 class='alert_success'>#{notice}</h4>"
    elsif alert
      message+="<h4 class='alert_warning'>#{alert}</h4>"
    end
    raw(message)
  end

  def status_lotacao(status)
    message=""
    if status=='ENCAMINHADO'
      message+="<span class='label label-warning'>#{status}</span>"
    elsif status=='À DISPOSIÇÃO DO NUPES'
      message+="<span class='label label-warning'>#{status}</span>"
    elsif status=='CANCELADO'
      message+="<span class='label label-important'>#{status}</span>"
    elsif status=='LOTADO'
      message+="<span class='label label-success'>#{status}</span> "
    elsif status=='NÃO LOTADO'
      message+="<span class='label label-important'>#{status}</span>"
    elsif status=='EM TRÂNSITO'
      message+="<span class='label label-warning'>#{status}</span>"
    else
      message=status
    end
    raw(message)
  end

  def novo_state_lotacao(lotacao,opcao)
    state = lotacao.state
    message=""
    if opcao == 'historico'
      if state=='encaminhado'
        message+="<span class='label label-info'>Em trânsito para o destino há #{contar_dias(lotacao.data_lotacao,'simples')}</span>"
      elsif state=='cancelado'
        message+="<span class='label label-danger'>Procedimento cancelado</span>"
      elsif state=='confirmado'
        message+="<span class='label label-success'>Ativo e confirmado</span> "
      elsif state=='devolvido'
        message+="<span class='label label-default'>Finalizado com devolução</span>"
      else
        message=state
      end
    elsif opcao == 'informacao'
      # if state=='encaminhado'
      #   message+="em trânsito para o destino"
      if state=='cancelado'
        message+="processo de lotação foi finalizado com cancelamento"
      # elsif state=='confirmado'
        # message+="Ativo e confirmado"
      elsif state=='devolvido'
        message+="processo de lotação foi finalizado com devolução"
      else
        message=state
      end
    end
    raw(message)
  end

  def contar_dias(data,opcao)
    diferenca = DateTime.now - data
    if opcao == 'simples'
      if diferenca == 1
        return "#{diferenca.to_i} dia"
      elsif diferenca > 1
        return "#{diferenca.to_i} dias"
      end
    elsif opcao == 'informacao'
      if diferenca == 1
        return ". Assim, contabiliza-se #{diferenca.to_i} dia sem labor efetivo"
      elsif diferenca > 1
        return ", Assim, contabiliza-se #{diferenca.to_i} dias sem labor efetivo"
      end
    end
  end

  def compativel(mess,comp)
    message=""
    if comp==true
      message+="<h7 class='mess_success' style='width: 99.5%;'>#{mess}</h7>"
    else
      message+="<h7 class='mess_error' style='width: 99.5%;'>#{mess}</h7>"
    end
    return raw(message)
  end


  def status(processo)
    s=Status.find :last,:conditions=>["processo_id=?",processo.id]
    if s
      return s.status
    else
      return "Processo sem status ativo"
    end
  end



  def sim_nao(objeto)
    if objeto==true
      return "Sim"
    else
      return "Não"
    end
  end


  def com_regencia(objeto)
    if objeto==true
      return " fazendo jus à regência de classe."
    else
      return " não fazendo jus à regência de classe."
    end
  end

  def tp_lotacao(lotacao)
    case lotacao
    when 'LOTACAO_REGULAR' then return 'LOTAÇÃO REGULAR'
    end
  end

  def rsn(jornada)
    if jornada=='40'
      return '26'
    elsif jornada=='20'
      return '12'
    end
  end

  def link_relativo(args)
    html=""

    args.each do |l|
      if l==true
        html+="<div class='breadcrumb_divider'></div><a href=#{:link} class='current'>#{:texto}</a>"
      else
        html+="<div class='breadcrumb_divider'></div><a href=#{:link} >#{:texto}</a>"
      end
    end
    return raw(html)
  end



  def placeholder(obj)
    if obj
      if obj.respond_to? "sigla"
        return obj.sigla
      else
        return obj.nome
      end
    else
      return raw("Nada Cadastrado")
    end
  end

  def cargo_disciplina(func)
    if func.cargo and func.cargo.tipo and func.cargo.tipo.nome=='Magistério/Docência' and func.disciplina_contratacao and func.nivel
      if func.disciplina_contratacao.nome != ' Não Definido'
        return "#{func.cargo.nome.upcase} DE #{func.disciplina_contratacao.nome.upcase}, #{func.nivel.nome.upcase}"
      else
        return "#{func.cargo.nome.upcase}, #{func.nivel.nome.upcase}"
      end
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Magistério/Docência'
      return "#{func.cargo.nome.upcase}, #{func.nivel.nome.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Comissão'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome!="Comissão"
      return "#{func.cargo.nome.upcase}, #{func.nivel.nome.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Administrativo'
      return "#{func.cargo.nome.upcase}, #{func.nivel.nome.upcase}"
    elsif func.cargo and func.nivel.nil? and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Administrativo'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo.nil?
      return "#{func.nivel.nome.upcase}"
    else
      return "#{func.cargo.nome.upcase}"
    end
  end



  def cargo_resumido(func)
    if func.cargo and func.cargo.tipo and func.cargo.tipo.nome=='Magistério/Docência' and func.disciplina_contratacao and func.nivel
      return "#{func.cargo.nome.upcase} DE #{func.disciplina_contratacao.nome.upcase}, #{func.nivel.codigo.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Magistério/Docência'
      return "#{func.cargo.nome.upcase}, #{func.nivel.codigo.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Comissão'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome!="Comissão"
      return "#{func.cargo.nome.upcase}, #{func.nivel.codigo.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Administrativo'
      return "#{func.cargo.nome.upcase}, #{func.nivel.codigo.upcase}"
    elsif func.cargo and func.nivel.nil? and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Administrativo'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.nivel and func.disciplina_contratacao.nil? and func.cargo.tipo.nil?
      return "#{func.cargo.nome.upcase}, #{func.nivel.codigo.upcase}"
    elsif func.cargo and func.nivel.nil? and func.disciplina_contratacao.nil? and func.cargo.tipo.nil?
      return "#{func.cargo.nome.upcase}"
    else
      return "Nada Cadastrado"
    end
  end

  def funcao(func)
    if func.cargo and func.cargo.tipo and func.cargo.tipo.nome=='Magistério/Docência' and func.disciplina_contratacao
      return "#{func.cargo.nome.upcase} DE #{func.disciplina_contratacao.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Magistério/Docência'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Comissão'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome!="Comissão"
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Administrativo'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo and func.cargo.tipo.nome=='Administrativo'
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo.nil?
      return "#{func.cargo.nome.upcase}"
    elsif func.cargo and func.disciplina_contratacao.nil? and func.cargo.tipo.nil?
      return "#{func.cargo.nome.upcase}"
    else
      return "Nada Cadastrado"
    end
  end


  def categorias_gerais(obj)
    if obj.categoria and ["Concurso de 2012","Estado Antigo","992","Ex-Ipesap","Estado Novo"].include?(obj.categoria.nome)
      return "EFETIVO ESTADUAL"
    elsif obj.categoria and ["Contrato Administrativo"].include?(obj.categoria.nome)
      return "CONTRATO ADMINISTRATIVO"
    elsif obj.categoria and ["Ex-Território do Amapá","Ministério da Educação","Ex-Território Federal do Amapá - Comissionado","Ministério da Educação - Comissionado"].include?(obj.categoria.nome)
      return "FEDERAL"
    elsif obj.categoria and ["Prefeitura - Permuta","Prefeitura - Cedido"]
      return "PREFEITURA"
    elsif obj.categoria and ["Sem Vínculo"]
      return "CARGO SEM VÍNCULO"
    else
      return "INDEFINIDO"
    end
  end


  def detalhes_str(obj)
    if obj
      return obj
    else
      return raw("Nada Cadastrado")
    end
  end

  def jornada(obj,resumido=false)
    if obj and obj.jornada and resumido==false
      return "#{obj.jornada} horas semanais"
    elsif obj and obj.jornada and resumido==true
      return "#{obj.jornada}H"
    else
      return "Nada Cadastrado"
    end
  end

  def email(obj)
    if obj and obj.pessoa and !obj.pessoa.email.blank?
      return obj.pessoa.email
    else
      return raw("Nada Cadastrado")
    end
  end

  def telefones(obj)
    if obj and !obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
      return "#{obj.telefone_residencial} / #{obj.telefone_celular}"
    elsif obj and obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
      return "#{obj.telefone_celular}"
    elsif obj and !obj.telefone_residencial.blank? and obj.telefone_celular.blank?
      return "#{obj.telefone_residencial}"
    else
      return raw("Nada Cadastrado")
    end
  end

  def telefones_agenda(obj)
    if obj
      if obj.pessoa and !obj.pessoa.telefone_residencial.blank? and !obj.pessoa.telefone_celular.blank?
        return "#{obj.pessoa.telefone_residencial} / #{obj.pessoa.telefone_celular}"
      elsif obj.pessoa and obj.pessoa.telefone_residencial.blank? and !obj.pessoa.telefone_celular.blank?
        return "#{obj.pessoa.telefone_celular}"
      elsif obj.pessoa and !obj.pessoa.telefone_residencial.blank? and obj.pessoa.telefone_celular.blank?
        return "#{obj.pessoa.telefone_residencial}"
      end
    else
      return raw("Nada Cadastrado")
    end
  end


  def cod(obj)
    if obj
      return obj.codigo
    else
      return raw("Nada Cadastrado")
    end
  end

  def detalhes(obj=nil,sigla=false)
    if obj
      if obj.respond_to? "sigla" and !obj.sigla.blank? and sigla==true
        return obj.sigla.upcase
      elsif obj.respond_to? "codigo" and !obj.codigo.blank? and sigla==true
        return obj.codigo.upcase
      elsif obj.respond_to? "nome" and !obj.nome.blank?
        return obj.nome.upcase
      elsif obj.respond_to? "nome" and !obj.nome.blank?
        return obj.nome.upcase
      elsif obj.respond_to? "username" and !obj.username.blank?
        return obj.username.upcase
      elsif obj.class==String and !obj.blank?
        return obj
      else
        return raw("Nada Cadastrado")
      end
    else
      return raw("Nada Cadastrado")
    end
  end

  def nome_e_cpf(funcionario)
    if funcionario.pessoa.present?
      if funcionario.pessoa.nome.present?
        if funcionario.pessoa.cpf.present?
          return "#{detalhes(funcionario.pessoa)} (CPF Nº #{detalhes(funcionario.pessoa.cpf)})"
        elsif funcionario.pessoa.cpf.nil? or funcionario.pessoa.cpf.blank?
          return "#{detalhes(funcionario.pessoa)} (CPF não localizado)}"
        end
      elsif funcionario.pessoa.nome.nil? or funcionario.pessoa.nome.cpf.blank?
        return "Nome não localizado"
      end
    else
      return "Nome não localizado"
    end
  end

  def cargo_e_matricula(funcionario)
    if funcionario.matricula.present?
      if funcionario.categoria.nome == "Ex-Território do Amapá" or funcionario.categoria.nome == "Ministério da Educação"
        return "#{cargo_disciplina(funcionario)}, SOB A MATRÍCULA SIAPE Nº #{funcionario.matricula}"
      else
        return "#{cargo_disciplina(funcionario)}, SOB A MATRÍCULA Nº #{funcionario.matricula}"
      end
    elsif funcionario.matricula.nil? or funcionario.matricula.blank?
      return "#{cargo_disciplina(funcionario)} (MATRÍCULA A SER GERADA PELA SEAD)"
    end
  end

  def enquadramento_funcional(funcionario)
    if funcionario.categoria.present?
      if funcionario.nivel.present?
        if funcionario.municipio_id.present?
          return "#{categoria_funcional(funcionario,'entidade_sigla')} (EM JORNADA DE #{jornada(funcionario.nivel).upcase} COM #{funcionario.municipio.nome.upcase} COMO MUNICIPIO DE OPÇÃO)"
        else
          return "#{categoria_funcional(funcionario,'entidade_sigla')} (EM JORNADA DE #{jornada(funcionario.nivel).upcase})"
        end
      elsif funcionario.nivel.nil? or funcionario.nivel.blank?
        return "#{categoria_funcional(funcionario,'entidade_sigla')}"
      end
    elsif funcionario.categoria.nil? or funcionario.categoria.blank?
      return "#{detalhes(funcionario.categoria.nome)}"
    end
  end

  def jornada_funcional(funcionario,opcao)
    if opcao == 'tabela'
      if funcionario.nivel.present?
        return "(EM JORNADA DE #{jornada(funcionario.nivel).upcase}"
      elsif funcionario.nivel.nil? or funcionario.nivel.blank?
        return "Atenção! A referência nível deve ser atualizada."
      end
    elsif opcao == 'qualificacao'
      if funcionario.nivel.present?
        return ", com jornada semanal de #{jornada(funcionario.nivel)}"
      elsif funcionario.nivel.nil? or funcionario.nivel.blank?
        return ""
      end
    end
  end

  def lotacao_anterior(funcionario)
    if funcionario and !funcionario.lotacoes.inativas.none?
      ultima = funcionario.lotacoes.inativas.order('data_lotacao desc').first
      if ultima.destino_type=="Escola" and ultima.destino.municipio
        return "#{funcionario.lotacoes.inativas.order('data_lotacao desc').first.destino.nome.upcase} (#{detalhes(ultima.destino.municipio)})"
      else
        return "#{funcionario.lotacoes.inativas.order('data_lotacao desc').first.destino.nome.upcase}"
      end
    else
      return "Sem registro anterior"
    end
  end

  def lotacao_atual(lotacao)
    if lotacao.destino_type=="Escola"
      if lotacao.destino.municipio.present?
        if lotacao.natureza.present?
          return "#{lotacao.destino.nome.upcase} (#{detalhes(lotacao.destino.municipio)}). NATUREZA DE ATUAÇÃO: #{lotacao.natureza.upcase}"
        elsif lotacao.natureza.nil? or lotacao.natureza.blank?
          return "#{lotacao.destino.nome.upcase} (#{detalhes(lotacao.destino.municipio)})"
        end
      elsif lotacao.destino.municipio.nil? or lotacao.destino.municipio.blank?
        return "#{lotacao.destino.nome.upcase}"
      end
    else
      return "#{lotacao.destino.nome.upcase}"
    end
  end

  def lotacao_atualizada(lotacao,opcao)
    if opcao == 'carta'
      if lotacao.destino_type=="Escola"
        if lotacao.destino.municipio.present?
          if lotacao.natureza.present?
            return "#{lotacao.destino.nome.upcase} (#{detalhes(lotacao.destino.municipio)}). NATUREZA DE ATUAÇÃO: #{lotacao.natureza.upcase}"
          elsif lotacao.natureza.nil? or lotacao.natureza.blank?
            return "#{lotacao.destino.nome.upcase} (#{detalhes(lotacao.destino.municipio)})"
          end
        elsif lotacao.destino.municipio.nil? or lotacao.destino.municipio.blank?
          return "#{lotacao.destino.nome.upcase}"
        end
      else
        return "#{lotacao.destino.nome.upcase}"
      end
    elsif opcao == 'qualificacao' #and lotacao.nil?
      if !lotacao.nil?
        if lotacao.destino_type=="Escola"
          if lotacao.destino.municipio.present?
            if lotacao.natureza.present?
              return ", exercendo sua atividade funcional no (a) #{lotacao.destino.nome.upcase} (#{detalhes(lotacao.destino.municipio)})#{jornada_funcional(lotacao.funcionario,"qualificacao")}"
            elsif lotacao.natureza.nil? or lotacao.natureza.blank?
              return ", exercendo sua atividade funcional no (a) #{lotacao.destino.nome.upcase} (#{detalhes(lotacao.destino.municipio)})#{jornada_funcional(lotacao.funcionario,"qualificacao")}"
            end
          elsif lotacao.destino.municipio.nil? or lotacao.destino.municipio.blank?
            return ", exercendo sua atividade funcional no (a) #{lotacao.destino.nome.upcase})#{jornada_funcional(lotacao.funcionario,"qualificacao")}"
end
else
  return ", exercendo sua atividade funcional no (a) #{lotacao.destino.nome.upcase})#{jornada_funcional(lotacao.funcionario,"qualificacao")}"
end
elsif lotacao.nil?
  return ", atualmente sem lotação definida"
end
end
end

def categoria_funcional(funcionario,opcao)
  if opcao == "simples"
    return "#{detalhes(funcionario.categoria)}"
  elsif opcao == "entidade_sigla"
    if funcionario.categoria.nil? or funcionario.categoria.blank?
      return "#{detalhes(funcionario.categoria)}"
    elsif !funcionario.categoria.nil?
      if funcionario.categoria.entidade.nil?
        return "#{detalhes(funcionario.categoria.entidade)}/#{detalhes(funcionario.categoria)}"
      elsif !funcionario.categoria.entidade.nil?
        return "#{detalhes(funcionario.categoria.entidade.sigla).upcase}/#{detalhes(funcionario.categoria)}"
      end
    end
  elsif opcao == "entidade_nome"
    if funcionario.categoria.present?
      if funcionario.categoria.entidade.present?
        return "#{funcionario.categoria.entidade.nome}/#{funcionario.categoria.nome}"
      elsif funcionario.categoria.entidade.nil? or funcionario.categoria.entidade.blank?
        return "#{funcionario.categoria}"
      end
    elsif funcionario.categoria.nil? or funcionario.categoria.blank?
      return "#{detalhes(funcionario.categoria)}"
    end
  elsif opcao == "qualificacao"
    if funcionario.categoria.present?
      if funcionario.categoria.nome == ''
        return "/#{funcionario.categoria.entidade.nome}/#{funcionario.categoria.nome}"
      elsif funcionario.categoria.entidade.nil? or funcionario.categoria.entidade.blank?
        return "/#{funcionario.categoria}"
      end
    elsif funcionario.categoria.nil? or funcionario.categoria.blank?
      return "#{detalhes(funcionario.categoria)}"
    end
  end
end
end
