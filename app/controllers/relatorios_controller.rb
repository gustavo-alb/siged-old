# -*- encoding : utf-8 -*-
class RelatoriosController < ApplicationController
  
  def sem_lotacao
    pasta = Workbook::Book.open("public/modelos/relatorio_sem_lotacao.xls")
    planilha = pasta.sheet.table
    linha_modelo = planilha[1]
    @funcionarios = Funcionario.sem_lotacao.joins(:categoria).where("categoria.nome not in (?)",["Ex-Território do Amapá", "Ministério da Educação","UDE", "Sem Vínculo","Ex-Território Federal do Amapá - Comissionado", "Ministério da Educação - Comissionado","Contrato Administrativo","Prefeitura - Cedido", "Prefeitura - Permuta"]).uniq.sort_by{|f|f.pessoa.nome}
    @funcionarios.each.with_index(2) do |f,i|
      planilha << linha_modelo.clone
      planilha[i][0] = f.pessoa.nome
      planilha[i][1] = f.pessoa.cpf
      planilha[i][2] = f.matricula
      planilha[i][3] = view_context.detalhes(f.categoria)
      planilha[i][4] = view_context.cargo_disciplina(f)
      planilha[i][5] = view_context.municipio(f).upcase
    end
    planilha.delete(linha_modelo)
    arquivo = File.open("/tmp/relatorio-sl-#{Time.now.strftime("%d-%m-%Y-%H-%M-%S")}.xls",'w')
    pasta.write_to_xls("#{arquivo.path}")
    send_file(arquivo.path,:filename=>"Relatório de Funcionários Sem Lotação.xls",:type=>"application/vnd.ms-excel")
  end


  def contrato_docente
    pasta = Workbook::Book.open("public/modelos/relatorio_docente.xls")
    planilha = pasta.sheet.table
    linha_modelo = planilha[1]
    @professores = Funcionario.where(:cargo_id=>Cargo.find_by_nome("PROFESSOR").id,:categoria_id=>Categoria.find_by_nome("Contrato Administrativo").id).sort_by{|f|f.pessoa.nome}
    @professores.each.with_index(2) do |f,i|
      planilha << linha_modelo.clone
      planilha[i][0] = f.pessoa.nome
      planilha[i][1] = f.pessoa.cpf
      planilha[i][2] = f.pessoa.rg
      planilha[i][3] = view_context.contato_simples(f.pessoa)
      planilha[i][4] = view_context.detalhes(f.disciplina_contratacao)
      planilha[i][5] = view_context.municipio(f).upcase
      planilha[i][6] = view_context.lotacao(f)
    end
    planilha.delete(linha_modelo)
    arquivo = File.open("/tmp/relatorio-#{Time.now.strftime("%d-%m-%Y-%H-%M-%S")}.xls",'w')
    pasta.write_to_xls("#{arquivo.path}")
    send_file(arquivo.path,:filename=>"Relatório Contratos Docentes.xls",:type=>"application/vnd.ms-excel")
  end

  def geral
    pasta = Workbook::Book.open("public/modelos/relatorio_geral.xls")
    planilha = pasta.sheet.table
    linha_modelo = planilha[1]
    @professores = Funcionario.all.sort_by{|f|f.pessoa.nome}
    @professores.each.with_index(2) do |f,i|
      planilha << linha_modelo.clone
      planilha[i][0] = f.pessoa.nome
      planilha[i][1] = f.pessoa.cpf
      planilha[i][2] = f.matricula
      planilha[i][3] = view_context.detalhes(f.cargo)
      planilha[i][4] = view_context.detalhes(f.disciplina_contratacao)
      planilha[i][5] = view_context.municipio(f).upcase
      planilha[i][6] = view_context.lotacao(f)
      planilha[i][7] = view_context.categorias_gerais(f)
    end
    planilha.delete(linha_modelo)
    arquivo = File.open("/tmp/relatorio-#{Time.now.strftime("%d-%m-%Y-%H-%M-%S")}.xls",'w')
    pasta.write_to_xls("#{arquivo.path}")
    send_file(arquivo.path,:filename=>"Relatório Geral.xls",:type=>"application/vnd.ms-excel")
  end

  def contrato_nao_docente
    pasta = Workbook::Book.open("public/modelos/relatorio_nao_docente.xls")
    planilha = pasta.sheet.table
    linha_modelo = planilha[1]
    @funcionarios = Funcionario.where("cargo_id <> ? and categoria_id = ?",Cargo.find_by_nome("PROFESSOR").id,Categoria.find_by_nome("Contrato Administrativo").id).sort_by{|f|f.pessoa.nome}
    @funcionarios.each.with_index(2) do |f,i|
      planilha << linha_modelo.clone
      planilha[i][0] = f.pessoa.nome
      planilha[i][1] = f.pessoa.cpf
      planilha[i][2] = f.pessoa.rg
      planilha[i][3] = view_context.contato_simples(f.pessoa)
      planilha[i][4] = view_context.detalhes(f.cargo)
      planilha[i][5] = view_context.municipio(f).upcase
      planilha[i][6] = view_context.lotacao(f)
    end
    planilha.delete(linha_modelo)
    arquivo = File.open("/tmp/relatorio-nd-#{Time.now.strftime("%d-%m-%Y-%H-%M-%S")}.xls",'w')
    pasta.write_to_xls("#{arquivo.path}")
    send_file(arquivo.path,:filename=>"Relatório Contratos Não Docentes.xls",:type=>"application/vnd.ms-excel")
  end
end

