# -*- encoding : utf-8 -*-
module EscolasHelper

  def contagem_servidores(contagem)
    if contagem == 1
      return "#{contagem} Servidor"
    elsif contagem > 1
      return "#{contagem} Servidores"
    elsif contagem < 1
      return "Nenhum servidor"
    end
  end

end

