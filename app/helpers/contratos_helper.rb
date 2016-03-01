# -*- encoding : utf-8 -*-
module ContratosHelper
    def contato(obj)
        if !obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
            return "TELEFONE FIXO: #{obj.telefone_residencial} E CELULAR: #{obj.telefone_celular}"
        elsif !obj.telefone_residencial.blank? and obj.telefone_celular.blank?
            return "TELEFONE FIXO: #{obj.telefone_residencial}"
        elsif obj.telefone_residencial.blank? and !obj.telefone_celular.blank?
            return "TELEFONE FIXO: #{obj.telefone_celular}"
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
end

