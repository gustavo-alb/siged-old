# -*- encoding : utf-8 -*-
module PessoasHelper
  # def endereco(pessoa)
  #   if !pessoa.endereco.blank? and !pessoa.numero.blank? and !pessoa.bairro.blank? and !pessoa.cidade.nil?
  #     return "#{pessoa.endereco}, #{pessoa.numero}, #{pessoa.bairro}, #{detalhes(pessoa.cidade)}"
  #   elsif !pessoa.endereco.blank? and !pessoa.numero.blank? and !pessoa.bairro.blank? and pessoa.cidade.nil?
  #     return "#{pessoa.endereco}, #{pessoa.numero}, #{pessoa.bairro}"
  #   end
  # end

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

  def telefones_pessoa(pessoa,opcao)
    if opcao == "tabela"
      if !pessoa.telefone_celular.blank? and !pessoa.telefone_residencial.blank?
        return "#{pessoa.telefone_celular}, #{pessoa.telefone_residencial}"
      elsif !pessoa.telefone_celular.blank?
        return "#{pessoa.telefone_celular}"
      elsif !pessoa.telefone_residencial.blank?
        return "#{pessoa.telefone_residencial}"
      else
        return "Nenhum telefone cadastrado."
      end
    elsif opcao == "qualificacao"
      if pessoa.telefone_celular.present?
        if pessoa.telefone_residencial.present?
          return ", tendo #{pessoa.telefone_celular} e #{pessoa.telefone_residencial} como números de contato"
        elsif pessoa.telefone_residencial.blank? or pessoa.telefone_residencial.nil?
          return ", tendo #{pessoa.telefone_celular} como número de contato"
        end
      elsif pessoa.telefone_celular.blank? or pessoa.telefone_celular.nil?
        if  pessoa.telefone_residencial.present?
          return ", tendo #{pessoa.telefone_residencial} como número de contato"
        elsif pessoa.telefone_residencial.blank? or pessoa.telefone_residencial.nil?
          return ", sem nenhum contato cadastrado"
        end
      end
    end
  end

  def orgao_do_funcionario(funcionario)
    if funcionario.orgao.present?
      return "#{funcionario.orgao.nome}"
    elsif funcionario.orgao.blank? or funcionario.orgao.nil?
      return "Secretaria de Estado da Educação do Amapá"
    end
  end

  def data_nomeacao(funcionario)
    if funcionario.data_nomeacao.present?
      return ", admitido em #{funcionario.data_nomeacao}"
    elsif funcionario.data_nomeacao.blank? or funcionario.data_nomeacao.nil?
      return ""
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
    elsif func and func.lotacoes.ativas.any?
      return "#{detalhes(func.lotacoes.ativas.first.destino)}"
    elsif func.nil?
      return "NÃO CADASTRADO"
    end
  end

  def lotacao_detalhes(func,opcao)
    if opcao == "ativa_simples"
      if func and func.lotacoes.ativas.none?
        return "NÃO LOTADO"
      elsif func.nil?
        return "NÃO CADASTRADO"
      elsif func and func.lotacoes.ativas.any?
        return "#{detalhes(func.lotacoes.ativas.first.destino)}"
      end
    elsif opcao == "ativa_detalhada"
      if func and func.lotacoes.ativas.none?
        return "NÃO LOTADO"
      elsif func.nil?
        return "NÃO CADASTRADO"
      elsif func.lotacoes.ativas.first.destino.municipio.nil?
        return "#{detalhes(func.lotacoes.ativas.first.destino)}"
      else !func.lotacoes.ativas.first.destino.municipio.nil?
        return "#{detalhes(func.lotacoes.ativas.first.destino)} - #{detalhes(func.lotacoes.ativas.first.destino.municipio)}"
      end
    elsif opcao == "todas_simples"
      return "oi"
    end
  end

  def l_ant(func)
    if func and func.lotacoes.inativas.none?
      return "NADA CADASTRADO"
    else
      return detalhes(func.lotacoes.inativas.order('data_lotacao desc').first.destino)
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

  def negritacao(objeto)
    html=""
    html+="<b>#{objeto}</b>"
    return raw(html)
  end

  def listagem_contratos(pessoa)
    table_head = %{
      <br>
    }
    table_body = ""
    table_body << "<div class='col-sm-12 col-md-12, well'>"
    table_body << "<br>"
    table_body << "<table class='table table-striped table-hover table-bordered table-condensed'>"
    # table_body << "<table class='table table-striped'>"
    table_body << "<thead>"
    table_body << "<tr>"
    table_body << "<th>MATRÍCULA</th>"
    table_body << "<th>CARGO</th>"
    table_body << "<th>OBSERVAÇÕES</th>"
    table_body << "<th>Ações</th>"
    table_body << "</tr>"
    table_body << "</thead>"
    table_body << "<tbody>"
    if pessoa.funcionarios.contratos_adm.count > 0
      pessoa.funcionarios.contratos_adm.each do |funcionario|
        table_body << "<tr>"
        table_body << "<td>#{detalhes(funcionario.matricula)}</td>"
        table_body << "<td>#{detalhes(funcionario.cargo)}</td>"
        table_body << "<td>#{observacao_contrato(funcionario,'tabela')}</td>"
        table_body << "<td>"
        table_body << "<div class='btn-group'>"
        table_body << "<button class='btn btn-default btn-xs dropdown-toggle' type='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>Opções<span class='caret'></span></button>"
        table_body << "<ul class='dropdown-menu dropdown-menu-right'>"
        table_body << "<li>#{link_to '<i class="fa fa-edit fa-fw"></i> Acompanhar contrato'.html_safe,pessoa_funcionario_contrato_path(pessoa,funcionario.id,:dados_pessoais)}</li>"

        table_body << "<li>#{link_to '<i class="fa fa-edit fa-fw"></i> Testar contrato'.html_safe,pessoa_funcionario_contrato_path(pessoa,funcionario.id,:first,:flow=>"facebook")}</li>"
        if can? :destroy, funcionario
          table_body << "<li>#{link_to "<i class='fa fa-eraser fa-fw'></i> Apagar".html_safe, pessoa_funcionario_path(pessoa,funcionario), method: :delete, data: { confirm: 'Are you sure?' }, :remote => true, :class => 'deletar_este'}</li>"
        end
        table_body << "</ul>"
        table_body << "</div>"
        table_body << "</td>"
        table_body << "</tr>"
      end
    else
      table_body << "<tr><td colspan='3'>Este funcionário não possui vínculos por Contrato Administrativo</td>"
      if pessoa.funcionarios.count > 0
        table_body << "<td>#{link_to "<i class='fa fa-eye fa-fw'></i> Visualizar".html_safe, pessoa_funcionarios_path(pessoa), :class => 'btn btn-default btn-xs'}</td>"
      else
        table_body << "<td><a class='btn btn-default btn-xs' data-toggle='tooltip' data-placement='left' title='Esta pessoa não possui nenhum registro funcional'><i class='fa fa-meh-o fa-fw'></i>Nenhum registro</a></td>"
      end
      table_body << "</tr>"




    end
    table_body << "</tbody>"
    table_body << "</table>"
    table_body << "</div>"
    #               <%# if can? :update,Funcionario and  can? :edit,Funcionario %>
    #               <%# end %>
    #               <%# if can? :read,Lotacao %>
    #               <li><%= link_to "<i class='fa fa-exchange fa-fw'></i> Lotações".html_safe,pessoa_funcionario_lotacoes_path(@pessoa,funcionario) %></li>
    #               <%# end %>
    #               <% if funcionario.categoria_contrato? %>
    #               <li><%= link_to "<i class='fa fa-exchange fa-fw'></i> Lotações".html_safe,pessoa_funcionario_lotacoes_path(@pessoa,funcionario) %></li>
    #               <% else %>
    #               bunda
    #               <% end %>

    #   </table>
    #
    html = table_head + table_body
    raw(html)
  end



end
