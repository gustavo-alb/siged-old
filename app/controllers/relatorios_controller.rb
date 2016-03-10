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
end

