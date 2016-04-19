# -*- encoding : utf-8 -*-
module ApplicationHelper

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
      return "#{func.cargo.nome.upcase} DE #{func.disciplina_contratacao.nome.upcase}, #{func.nivel.nome.upcase}"
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

  def jornada(obj)
    if obj and obj.jornada
      return "#{obj.jornada} horas semanais"
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
      if obj.respond_to? "nome" and !obj.nome.blank?
        return obj.nome.upcase
      elsif obj.respond_to? "sigla" and !obj.sigla.blank? and sigla==true
        return obj.sigla.upcase
      elsif obj.respond_to? "codigo" and !obj.codigo.blank? and sigla==true
        return obj.codigo.upcase
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

end
