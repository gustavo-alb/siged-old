# -*- encoding : utf-8 -*-
module PessoasHelper
  def endereco(pessoa)
    if !pessoa.endereco.blank? and !pessoa.numero.blank? and !pessoa.bairro.blank? and !pessoa.cidade.nil?
      return "#{pessoa.endereco}, #{pessoa.numero}, #{pessoa.bairro}, #{detalhes(pessoa.cidade)}"
    elsif !pessoa.endereco.blank? and !pessoa.numero.blank? and !pessoa.bairro.blank? and pessoa.cidade.nil?
      return "#{pessoa.endereco}, #{pessoa.numero}, #{pessoa.bairro}"
    end
  end

  def telefones(pessoa)
    if !pessoa.telefone_celular.blank? and !pessoa.telefone_residencial.blank?
      return "#{pessoa.telefone_celular}, #{pessoa.telefone_residencial}"
    elsif !pessoa.telefone_celular.blank?
      return "#{pessoa.telefone_celular}"
    elsif !pessoa.telefone_residencial.blank?
      return "#{pessoa.telefone_residencial}"
    else
      return "Nenhum telefone cadastrado."
    end
  end

  def local(func)
    texto=""
    if !func.lotacoes.atual.none? and func.status_lotacao=="LOTADO" or func.status_lotacao=="EM TRÂNSITO"
      texto+="#{func.status_lotacao}/#{destino(func.lotacoes.inativas[0])}"
    elsif !func.lotacoes.size.nil? and func.status_lotacao=="À DISPOSIÇÃO"
      texto+="#{func.status_lotacao}"
    else texto+="#{func.status_lotacao}"
    end
    return texto
  end

  def lotacao(func)
    if func and func.lotacoes.ativas.none?
      return "NÃO LOTADO"
    else
      return detalhes(func.lotacoes.ativas.first.destino)
    end
  end



  def l_ant(func)
    if func and func.lotacoes.inativas.none?
      return "NADA CADASTRADO"
    else
      return detalhes(func.lotacoes.inativas('data_lotacao desc').first.destino)
    end
  end


  def foto(pessoa)
    resultado2=""
    if !pessoa.fotos.none?
      foto = pessoa.fotos.last
      resultado2+="<div class='overview_total'>"
      resultado2+="<p class='overview_day'>Fotografia</p>"
      resultado2+="<p class='overview_count'></p>"
      resultado2+="<p class='overview_type'>#{image_tag(foto.imagem.url(:foto))}</p>"
    else
      resultado2+="<p class='overview_type'>#{image_tag('/images/noimage.png')}</p>"
      resultado2+="<p class='overview_tipo' align='center'>#{link_to 'Cadastrar Foto Usando a Web-Cam',new_pessoa_foto_path(@pessoa)}</p><br/>"

    end
    resultado2+="</div>"
    return raw(resultado2)
  end

  def negritar(pessoa)
    html=""
    html+="<b>#{pessoa.nome}</b>"
    return raw(html)
  end

end
