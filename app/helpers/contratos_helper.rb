# -*- encoding : utf-8 -*-
module ContratosHelper
  def contato(obj)
    if !obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
      return "TELEFONE FIXO: #{obj.telefone_residencial} E CELULAR: #{obj.telefone_celular}"
    elsif !obj.telefone_residencial.blank? and obj.telefone_celular.blank?
      return "TELEFONE FIXO: #{obj.telefone_residencial}"
    elsif obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
      return "TELEFONE CELULAR: #{obj.telefone_celular}"
    else
      return "SEM CONTATOS"
    end
  end

  def contato_simples(obj)
    if !obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
      return "#{obj.telefone_residencial} e #{obj.telefone_celular}"
    elsif !obj.telefone_residencial.blank? and obj.telefone_celular.blank?
      return "#{obj.telefone_residencial}"
    elsif obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
      return "#{obj.telefone_celular}"
    else
      return "SEM CONTATOS"
    end
  end

  def endereco(obj)
    if !obj.endereco.blank? and !obj.numero.blank? and !obj.bairro.blank?
      if obj.complemento.blank?
        return "#{obj.endereco}, Nº #{obj.numero}, Bairro #{obj.bairro}"
      else
        return "#{obj.endereco}, Nº #{obj.numero}, Bairro #{obj.bairro}, #{obj.complemento}"
      end
    end
  end

  def municipio_destino(obj)
    if obj.municipio and obj.respond_to?(:distrito) and !obj.distrito.blank?
      return raw("#{obj.municipio.nome}/#{obj.distrito}")
    elsif obj.municipio
      return raw("#{obj.municipio.nome}")
    else
      return "MACAPÁ"
    end
  end

  def recomendacao_contrato(contrato,opcao)
    if opcao == 'modal'
      if contrato and contrato.created_at == contrato.updated_at
        return "<li><font color='red'>Registro criado com informações a partir do modelo padrão de Contrato Administrativo.</font></li><li><font color='red'><b>Recomenda-se atualização imediata ou exclusão do registro.</b></font></li>"
      else
        return ""
      end
    else
      return ""
    end
  end

end

