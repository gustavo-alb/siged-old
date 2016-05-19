# -*- encoding : utf-8 -*-
module FuncionariosHelper
  def situacao(f)
    if f and f.situacao
      sit = f.situacao
      return raw("<span class='label label-default label-#{sit.cor}'>#{sit.nome.upcase}</span>")
    end
  end

  def desc(obj)
    if obj
      return obj.nome
    else
      return ""
    end
  end

  def quadro(funcionario)
    if funcionario.categoria and funcionario.entidade
      return "#{funcionario.entidade.nome}/#{funcionario.categoria.nome}"
    elsif funcionario.entidade and funcionario.categoria.nil?
      return funcionario.entidade.nome
    elsif funcionario.entidade.nil? and funcionario.categoria
      return funcionario.categoria.nome
    else
      return "NADA CADASTRADO"
    end
  end

  def turmas(f)
    t = []
    if f and !f.especificacoes.none?
      f.especificacoes.each do |e|
        if !e.turma.nil?
          t << e.turma.nome
        elsif e.turma.nil? and !e.ambiente.nil?
          t << e.ambiente.nome
        end
      end
    end
    if !t.none?
      return raw("O funcionário está especificado em #{pluralize(t.count,'turma','turmas')}: #{t.to_sentence}.")
    else
      return raw("O funcionário não está especificado em nenhum ambiente!")
    end
  end

  def cor_rsd(funcionario)
    if funcionario.rsn==12
     if funcionario.rsd <=4
       return raw("<font color=blue> #{funcionario.rsd} </font>")
     else
       return raw("<font color=red> #{funcionario.rsd} </font>")
     end
   elsif funcionario.rsn==24
    if funcionario.rsd <=4
     return raw("<font color=blue> #{funcionario.rsd} </font>")
   else
     return raw("<font color=red> #{funcionario.rsd} </font>")
   end
 end
end


def localizacao(func)
  texto=""
  if func.lotacoes.nil?
   texto+= "#{func.lotacao_recad}"
 else
  texto+= "#{destino(func.lotacoes.finalizada[-1])}"
end
return texto
end


def municipio_distrito(func)
  if func.municipio and func.distrito.nil?
    return raw("<p><b>Município de Opção:</b> #{detalhes(func.municipio)}</p>")
  elsif func.municipio and func.distrito
    return raw("<p><b>Município de Opção:</b> #{detalhes(func.municipio)}</p> <p><b>Distrito/Área de Opção:</b> #{detalhes(func.municipio)}</p>")
  else
    return ""
  end
end

def municipio_de_opcao(funcionario)
  if funcionario.municipio.nil? and funcionario.distrito.nil?
    return ""
  elsif !funcionario.municipio.nil? and funcionario.distrito.nil?
    return "#{detalhes(funcionario.municipio)}"
  elsif !funcionario.municipio.nil? and !funcionario.distrito.nil?
    return "#{detalhes(funcionario.municipio)}/#{detalhes(funcionario.distrito)}"
  end
end
  # - #{detalhes(func.lotacoes.ativas.first.destino.municipio)}

  def dest(lotacao)
    if lotacao
      if lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.nil?
        return "#{lotacao.orgao.nome}"
      elsif lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.size>0
        return "#{lotacao.escola.nome}/#{lotacao.orgao.nome}"
      else
        return "#{lotacao.escola.nome}"

      end
    else
      return "Não lotado"
    end
  end

end

