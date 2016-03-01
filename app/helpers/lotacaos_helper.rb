# -*- encoding : utf-8 -*-
module LotacaosHelper

  def status_l(status)

    if status=='FINALIZADO'
      return true
  else
      return false
  end
end

def municipio_lotacao(lot)
    if lot and lot.destino_type=="Escola" and lot.destino.municipio
        return lot.destino.municipio.nome
    elsif lot and lot.destino_type=="Departamento"
        return "Macapá"
    else
        return "NADA CADASTRADO"
    end
end

def municipio(func)
  if func.municipio and func.distrito
    return raw("#{func.municipio.nome}/#{func.distrito.nome }")
elsif func.municipio and func.distrito.nil?
    return raw("#{func.municipio.nome}")
else
    return ""
end
end


def carencia(valor,ambiente=false)
    if valor>0 and ambiente==false
        return "#{valor} horas"
    elsif valor>0 and ambiente==true
        return pluralize(valor,"professor","professores")
    else
        return "nenhuma"
    end
end

def magisterio(f)
    if f and f.cargo
        if f.cargo.tipo.nome=='Magistério/Docência'
            return raw(", com disponibilidade de regência inicial até #{f.rsn},&nbsp;<b>fazendo jus à
                regência de classe.</b>")
        else
            return "."
        end
    end
end

def confirmacao(f)
    if f and f.cargo
        if f.cargo.tipo.nome=='Magistério/Docência'
            return raw(", com disponibilidade de regência inicial até #{f.rsn},&nbsp;<b>fazendo jus à
                regência de classe.</b>")
        else
            return "."
        end
    end
end

def codigo_lotacao(lotacao)
    if !lotacao.escola.nil?
        return "#{lotacao.escola.orgao.codigo}"
    elsif !lotacao.departamento.nil?
        return "#{lotacao.orgao.codigo}"
    elsif lotacao.departamento.nil? and lotacao.escola.nil?
        return "#{lotacao.funcionario.orgao.codigo}"
    else
        return raw("<font color=red><b>Nada Cadastrado</b></font>")
    end
end

def tipo_lotacao(l)
    if l.tipo_lotacao=="PROLABORE"
        return "PRÓ-LABORE"
    else
        return l.tipo_lotacao
    end
end


def header_ponto(lotacao)
    if !lotacao.escola.nil?
        return "#{lotacao.escola.nome.upcase}"
    elsif !lotacao.departamento.nil?
        return "#{lotacao.departamento.nome.upcase}"
    else
        return ""
    end
end

def destino(lotacao)
  if lotacao and lotacao.destino
    if lotacao.destino_type=="Escola"
        return lotacao.destino.nome
    elsif lotacao.destino_type=="Departamento"
        return "#{lotacao.destino.sigla}/#{lotacao.destino.orgao.sigla}"
    elsif lotacao.destino_type=="Orgao"
        return lotacao.destino.sigla
    end
else
    return "LOTAÇÃO INVÁLIDA"
end
end



def destino_ponto(lotacao)
   if lotacao
       if lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
        return "#{lotacao.departamento.sigla}/#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="ESPECIAL" and !lotacao.escola.nil?
        return "#{lotacao.escola.nome}/#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and !lotacao.departamento.nil? and lotacao.escola.nil?
        return "#{lotacao.departamento.sigla}/#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL"  and !lotacao.escola.nil? and lotacao.departamento.nil?
        return "#{lotacao.escola.nome}/#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="COMISSÃO" and !lotacao.departamento.nil? and lotacao.escola.nil?
        return "#{lotacao.departamento.sigla}/#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="COMISSÃO" and !lotacao.escola.nil? and lotacao.departamento.nil?
        return "#{lotacao.escola.nome}/#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
        return "#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="SUMARIA ESPECIAL" and lotacao.escola.nil? and !lotacao.orgao.nil? and lotacao.departamento.nil?
        return "#{lotacao.orgao.sigla}"
    elsif lotacao.tipo_lotacao=="SUMARIA" or lotacao.tipo_lotacao=="REGULAR" or lotacao.tipo_lotacao=="PROLABORE"
        return "#{lotacao.escola.nome}"
    elsif lotacao.escola.nil? and lotacao.orgao.nil? and lotacao.departamento.nil?
        return raw("<b><font color=red>LOTAÇÃO INVÁLIDA</b></font>")
    end
end
end



end 

