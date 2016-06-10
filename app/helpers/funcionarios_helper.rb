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
    return texto
  end
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

def observacao_contrato(funcionario,opcao)
  if opcao == 'modal'
    if funcionario.situacao.nome == 'Ativo' and funcionario.categoria_contrato?
      if funcionario.matricula.present?
        if !funcionario.cargo_nat_especial?
          return "<ul><li>Status ATIVO!</li><li>Contrato atualizado.</li></ul>"
        else
          return "<ul><li>Status ATIVO!</li><li><font color='red'>Favor confirmar cargo, município  de opção e data de admissão do contrato.</font></li></ul>"
        end
      elsif funcionario.matricula.nil? or funcionario.matricula.blank?
        if !funcionario.cargo_nat_especial?
          return "<ul><li>Status ATIVO!</li><li><font color='red'>Matrícula a ser criada pela SEAD.</font></li><li><font color='red'>Favor confirmar cargo, município  de opção e data de admissão do contrato.</font></li></ul>"
        else
          return "<ul><li>Status ATIVO!</li><li><font color='red'>Matrícula a ser criada pela SEAD.</font></li><li><font color='red'>Favor confirmar cargo, município de opção e data de admissão do contrato.</font></li></ul>"
        end
      end
    elsif funcionario.situacao.nome == 'Inativo' and funcionario.categoria_contrato?
      if funcionario.matricula.present?
        if !funcionario.cargo_nat_especial?
          return "<ul><li><font color='red'>Status INATIVO!</font></li><li><font color='red'>Favor confirmar município de opção e data de admissão do contrato.</font></li></ul>"
        else
          return "<ul><li><font color='red'>Status INATIVO!</font></li><li><font color='red'>Favor confirmar cargo, município de opção e data de admissão do contrato.</font></li>#{recomendacao_contrato(funcionario.contrato,'modal')}</ul>"
        end
      elsif funcionario.matricula.nil? or funcionario.matricula.blank?
        if !funcionario.cargo_nat_especial?
          return "<ul><li><font color='red'>Status INATIVO!</font></li><li><font color='red'>Matrícula a ser criada pela SEAD.</font></li><li><font color='red'>Confirmar cargo, município de opção e admissão.</font></li>#{recomendacao_contrato(funcionario.contrato,'modal')}</ul>"
        else
          return "<ul><li><font color='red'>Status INATIVO!</font></li><li><font color='red'>Matrícula a ser criada pela SEAD.</font></li><li><font color='red'>Favor confirmar cargo, município  de opção e data de admissão do contrato.</font></li>#{recomendacao_contrato(funcionario.contrato,'modal')}</ul>"
        end
      end
    end
  elsif opcao == 'tabela'
    if funcionario.situacao.nome == 'Ativo' and funcionario.categoria_contrato?
      if funcionario.matricula.present?
        if !funcionario.cargo_nat_especial?
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-success btn-xs'>Há observações. Veja aqui.</a>"
        else
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-warning btn-xs'>Há observações. Veja aqui.</a>"
        end
      elsif funcionario.matricula.nil? or funcionario.matricula.blank?
        if !funcionario.cargo_nat_especial?
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-warning btn-xs'>Há observações. Veja aqui.</a>"
        else
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-warning btn-xs'>Há observações. Veja aqui.</a>"
        end
      end
    elsif funcionario.situacao.nome == 'Inativo' and funcionario.categoria_contrato?
      if funcionario.matricula.present?
        if !funcionario.cargo_nat_especial?
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-danger btn-xs'>Há restrições. Veja aqui.</a>"
        else
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-danger btn-xs'>Há restrições. Veja aqui.</a>"
        end
      elsif funcionario.matricula.nil? or funcionario.matricula.blank?
        if !funcionario.cargo_nat_especial?
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-danger btn-xs'>Há restrições. Veja aqui.</a>"
        else
          return "<a role='button' data-toggle='modal' data-target='#observacao_contrato-#{funcionario.id}-notes' class='btn btn-danger btn-xs'>Há restrições. Veja aqui.</a>"
        end
      end
    end
  end

end

def modal_observacao_contrato(funcionario)
  table_head = %{
    <br>
  }
  table_body = ""
  table_body << "<!-- Modal observacao_contrato -->"
  table_body << "<div class='modal fade' id='observacao_contrato-#{funcionario.id}-notes' tabindex='-1' role='dialog' aria-labelledby='observacao_contrato-#{funcionario.id}-label' aria-hidden='true'>"
  table_body << "<div class='modal-dialog'>"
  table_body << "<div class='modal-content'>"
  table_body << "<div class='modal-header'>"
  table_body << "<h4 class='modal-title' id='observacao_contrato-#{funcionario.id}-label' align='center'>"
  table_body << "#{funcionario.pessoa.nome}"
  table_body << "</h4>"
  table_body << "</div>"
  table_body << "<div class='modal-body'>"
  table_body << "<div class='well'>"
  table_body << ""
  table_body << "<p><b>Observações:<b></p>"
  table_body << "#{observacao_contrato(funcionario,'modal')}"
  table_body << "</div>"
  table_body << "</div>"
  table_body << "<div class='modal-footer'>"
  table_body << "<button type='button' class='btn btn-primary' data-dismiss='modal'>Close</button>"
  table_body << "</div>"
  table_body << "</div>"
  table_body << "</div>"
  table_body << "</div><!-- Modal observacao_contrato -->"

  html = table_head + table_body
  raw(html)
end

def disciplina_contratacao(funcionario,opcao)
  if opcao == 'isolado'
    if funcionario.disciplina_contratacao and funcionario.disciplina_contratacao.nome != "ZIndefinido"
      return "#{detalhes(funcionario.disciplina_contratacao)}"
    elsif funcionario.disciplina_contratacao and funcionario.disciplina_contratacao.nome == "ZIndefinido"
      return "Nada Cadastrado"
    else
      return "Nada Cadastrado"
    end
  else
  end
end

def modal_observacao_contrato_p(pessoa)
  table_head = %{
    <br>
  }
  table_body = ""
  Pessoa.find(pessoa.id).funcionarios.contratos_adm.each do |funcionario|
    table_body << "<!-- Modal observacao_contrato -->"
    table_body << "<div class='modal fade' id='observacao_contrato-#{funcionario.id}-notes' tabindex='-1' role='dialog' aria-labelledby='observacao_contrato-#{funcionario.id}-label' aria-hidden='true'>"
    table_body << "<div class='modal-dialog'>"
    table_body << "<div class='modal-content'>"
    table_body << "<div class='modal-header'>"
    table_body << "<h4 class='modal-title' id='observacao_contrato-#{funcionario.id}-label' align='center'>"
    table_body << "#{funcionario.pessoa.nome}"
    table_body << "</h4>"
    table_body << "</div>"
    table_body << "<div class='modal-body'>"
    table_body << "<div class='well'>"
    table_body << "<dl class='dl-horizontal'>"
    table_body << "<dt><strong>Matricula:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.matricula)}</dd>"
    table_body << "<dt><strong>Cargo:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.cargo)}</dd>"
    if funcionario.cargo and funcionario.cargo.nome=="PROFESSOR"
    # and funcionario.disciplina_contratacao.nome != "ZIndefinido"
    table_body << "<dt><strong>Disciplina:</strong></dt>"
      # table_body << "<dd>#{detalhes(funcionario.disciplina_contratacao)}</dd>"
      table_body << "<dd>#{disciplina_contratacao(funcionario,"isolado")}</dd>"
    end
    table_body << "<dt><strong>Quadro:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.entidade)}</dd>
    <dt><strong>Categoria:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.categoria)}</dd>"
    table_body << "<dt><strong>Referência/Nivel:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.nivel)}</dd>"
    table_body << "<dt><strong>Orgão:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.orgao)}</dd>"
    table_body << "<dt><strong>Admissão:</strong></dt>"
    table_body << "<dd>#{funcionario.data_nomeacao.to_s_br}</dd>"
    table_body << "<dt><strong>Município de Opção:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.municipio)}</dd>"
    table_body << "<dt><strong>Observacao:</strong></dt>"
    table_body << "<dd>#{detalhes(funcionario.observacao)}</dd>"
    table_body << "</dl>"
    table_body << "<h4><b>Observações:</b></h4>"
    table_body << "#{observacao_contrato(funcionario,'modal')}"
    table_body << "</div>"
    table_body << "</div>"
    table_body << "<div class='modal-footer'>"
    table_body << "<button type='button' class='btn btn-primary' data-dismiss='modal'>Close</button>"
    table_body << "</div>"
    table_body << "</div>"
    table_body << "</div>"
    table_body << "</div><!-- Modal observacao_contrato -->"
  end

  html = table_head + table_body
  raw(html)
end

def municipio_opcao(funcionario)
  if funcionario.categoria
    if funcionario.categoria.nome == 'Estado Novo' or funcionario.categoria.nome == 'Concurso de 2012' or funcionario.categoria_contrato?
      return ", com #{municipio_de_opcao(funcionario)} como município de opção"
    end
  else
    return ""
  end
end

def qualificacao_funcional_regime(funcionario,opcao)
  if opcao == 'qualificacao'
    if funcionario.categoria
      if funcionario.categoria.nome == 'Estado Antigo' or funcionario.categoria.nome == 'Estado Novo' or funcionario.categoria.nome == 'Concurso de 2012' or funcionario.categoria.nome == '992' or funcionario.categoria_contrato?
        return " e pertencente ao Quadro de Pessoal Civil do Governo do Estado do Amapá/#{funcionario.categoria.nome}, regido pela Lei No 066, de 03 de março de 1993"
      elsif funcionario.categoria.nome == 'Ex-Ipesap'
        return ", retroagindo seus efeitos a contar de 11 de abril de 2000, pertencente ao Quadro de Pessoal Civil do Governo do Estado do Amapá/#{funcionario.categoria.nome}, regido pela Lei No 066, de 03 de março de 1993"
        # [Ex-992 Ex-Ipesap através do Concurso Público de 2005 através do Concurso Público de 2012 categoria_contrato]]"
      elsif funcionario.categoria.nome == 'Ex-Território do Amapá'
        return " e pertencente ao Quadro de Pessoal Civil da União/Ex-Território do Amapá, regido pela Lei No 8.112, de 11 de dezembro de 1990 e No 066, de 03 de março de 1993"
      elsif funcionario.categoria.nome == 'Ministério da Educação'
        return " e pertencente ao Quadro de Pessoal Civil da União/Ministério da Educação, regido pela Lei No 8.112, de 11 de dezembro de 1990 e No 066, de 03 de março de 1993"
      else
        return ""
      end
    else
      return ""
    end
  else
  end
end

end

