# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160302120321) do

  create_table "add_usuario_to_pontos", :force => true do |t|
    t.integer  "usuario_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "administracao_logs", :force => true do |t|
    t.text     "log"
    t.integer  "user_id"
    t.date     "data"
    t.string   "tipo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "administracao_migracoes", :force => true do |t|
    t.integer  "entidade_id"
    t.string   "tipo"
    t.integer  "numero_registros"
    t.integer  "contador"
    t.string   "origem"
    t.string   "motivo"
    t.string   "migracao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "arquivo_file_name"
    t.string   "arquivo_content_type"
    t.integer  "arquivo_file_size"
    t.datetime "arquivo_updated_at"
  end

  create_table "administracao_tarefas", :force => true do |t|
    t.string   "tipo"
    t.date     "data"
    t.boolean  "executado"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "arquivo_file_name"
    t.string   "arquivo_content_type"
    t.integer  "arquivo_file_size"
    t.datetime "arquivo_updated_at"
    t.string   "classe"
    t.string   "atributo"
    t.string   "valor"
  end

  create_table "ambiente_fisicos", :force => true do |t|
    t.integer  "ambiente_id"
    t.integer  "matriz_id"
    t.integer  "serie_id"
    t.string   "turno"
    t.integer  "escola_id"
    t.integer  "entidade_id"
    t.string   "tipo_ambiente"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ambientes", :force => true do |t|
    t.string   "nome"
    t.integer  "tipo_ambiente_id"
    t.boolean  "ativo",            :default => true
    t.integer  "escola_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "descricao"
    t.integer  "ano_letivo"
    t.integer  "setting_id"
    t.integer  "entidade_id"
  end

  add_index "ambientes", ["setting_id"], :name => "index_ambientes_on_setting_id"
  add_index "ambientes", ["tipo_ambiente_id"], :name => "index_ambientes_on_tipo_ambiente_id"

  create_table "ambientes_turnos", :id => false, :force => true do |t|
    t.integer "turno_id"
    t.integer "ambiente_id"
  end

  create_table "ano_letivos", :force => true do |t|
    t.integer  "escola_id"
    t.date     "inicio"
    t.date     "termino"
    t.text     "informacoes"
    t.integer  "ano"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "arquivo_documentos", :force => true do |t|
    t.string   "tipo"
    t.integer  "dono_id"
    t.datetime "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "arquivos", :force => true do |t|
    t.string   "numero"
    t.text     "observacao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  create_table "auto_nums", :force => true do |t|
    t.string   "tipo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "boletins_funcionais", :force => true do |t|
    t.integer  "funcionario_id"
    t.string   "mes"
    t.string   "ano"
    t.string   "folha"
    t.string   "tipo",           :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  add_index "boletins_funcionais", ["funcionario_id"], :name => "index_boletins_funcionais_on_funcionario_id"

  create_table "boletins_pessoais", :force => true do |t|
    t.integer  "pessoa_id"
    t.string   "mes"
    t.string   "ano"
    t.string   "folha"
    t.string   "tipo",        :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  add_index "boletins_pessoais", ["pessoa_id"], :name => "index_boletins_pessoais_on_pessoa_id"

  create_table "carencias", :force => true do |t|
    t.integer  "escola_id"
    t.integer  "disciplina_id"
    t.string   "status"
    t.date     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ano_letivo_id"
    t.string   "disciplina"
    t.string   "escola"
    t.string   "carga_horaria"
  end

  create_table "cargos", :force => true do |t|
    t.string   "codigo"
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tipo_id"
    t.integer  "entidade_id"
  end

  add_index "cargos", ["codigo"], :name => "index_cargos_on_codigo"
  add_index "cargos", ["nome"], :name => "index_cargos_on_nome"

  create_table "carta", :force => true do |t|
    t.integer  "funcionario_id"
    t.integer  "lotacao_id"
    t.boolean  "impressa",           :default => false
    t.string   "carta_file_name"
    t.string   "carta_content_type"
    t.integer  "carta_file_size"
    t.integer  "carta_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categoria", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.string   "lei"
    t.string   "sigla"
  end

  create_table "categoria_ensinos", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categoria_funcionarios", :id => false, :force => true do |t|
    t.integer "categoria_id"
    t.integer "funcionario_id"
  end

  create_table "cidades", :force => true do |t|
    t.string   "nome"
    t.integer  "estado_id"
    t.string   "cep"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colapso_grupo", :id => false, :force => true do |t|
    t.integer "grupo_educacional_id"
    t.integer "funcionario_id"
    t.integer "user_id"
  end

  create_table "colapso_matrizes", :id => false, :force => true do |t|
    t.integer "matriz_id"
    t.integer "serie_id"
    t.integer "disciplina_id"
  end

  create_table "comissionados", :force => true do |t|
    t.integer  "funcionario_id"
    t.string   "tipo"
    t.date     "data"
    t.text     "motivo"
    t.string   "decreto"
    t.date     "data_publicacao"
    t.integer  "orgao_id"
    t.string   "descricao_comissao"
    t.boolean  "valido"
    t.integer  "comissionado_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ativo",              :default => true
    t.string   "decreto_exoneracao"
    t.date     "data_exoneracao"
    t.integer  "entidade_id"
    t.integer  "escola_id"
    t.integer  "departamento_id"
    t.integer  "tipo_destino_id"
  end

  create_table "configuracao_pontos", :force => true do |t|
    t.integer  "ponto_id"
    t.datetime "hora_entrada_manha"
    t.string   "tipo_entrada_manha"
    t.datetime "hora_saida_manha"
    t.string   "tipo_saida_manha"
    t.datetime "hora_entrada_tarde"
    t.string   "tipo_entrada_tarde"
    t.datetime "hora_saida_tarde"
    t.string   "tipo_saida_tarde"
    t.boolean  "permitir_hora_extra",       :default => false
    t.boolean  "permitir_banco_de_horas",   :default => false
    t.integer  "entidade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "hora_limite_entrada_manha"
    t.datetime "hora_limite_saida_manha"
    t.datetime "hora_limite_entrada_tarde"
    t.datetime "hora_limite_saida_tarde"
  end

  create_table "contrato_anteriores", :force => true do |t|
    t.string   "nome"
    t.string   "cpf"
    t.string   "rg"
    t.string   "matricula"
    t.string   "lotacao"
    t.string   "cargo"
    t.string   "disciplina"
    t.string   "municipio"
    t.string   "distrito"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contratos", :force => true do |t|
    t.integer  "numero"
    t.decimal  "salario"
    t.integer  "funcionario_id"
    t.integer  "lotacao_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "curriculos", :force => true do |t|
    t.integer  "matriz_id"
    t.integer  "disciplina_id"
    t.integer  "serie_id"
    t.string   "classe"
    t.string   "area"
    t.integer  "horas_semanal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curriculos", ["disciplina_id"], :name => "index_curriculos_on_disciplina_id"
  add_index "curriculos", ["matriz_id"], :name => "index_curriculos_on_matriz_id"
  add_index "curriculos", ["serie_id"], :name => "index_curriculos_on_serie_id"

  create_table "departamentos", :force => true do |t|
    t.string   "nome"
    t.string   "sigla"
    t.integer  "orgao_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tipo_destino_id"
    t.integer  "pai_id"
    t.integer  "filho_id"
    t.string   "telefone"
    t.string   "hierarquia",      :limit => nil
    t.integer  "entidade_id"
    t.integer  "municipio_id"
  end

  add_index "departamentos", ["orgao_id"], :name => "index_departamentos_on_orgao_id"
  add_index "departamentos", ["pai_id"], :name => "index_departamentos_on_pai_id"
  add_index "departamentos", ["tipo_destino_id"], :name => "index_departamentos_on_tipo_destino_id"

  create_table "descricao_cargos", :force => true do |t|
    t.string   "codigo"
    t.string   "nome"
    t.integer  "tipo_id"
    t.integer  "nivel_cargo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  add_index "descricao_cargos", ["nivel_cargo_id"], :name => "index_descricao_cargos_on_nivel_cargo_id"
  add_index "descricao_cargos", ["tipo_id"], :name => "index_descricao_cargos_on_tipo_id"

  create_table "disciplinas", :force => true do |t|
    t.string   "nome"
    t.string   "codigo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grupo"
  end

  create_table "disciplinas_funcionarios", :id => false, :force => true do |t|
    t.integer "disciplina_id"
    t.integer "funcionario_id"
    t.integer "disciplina_contratacao_id"
  end

  create_table "disciplinas_habilitacoes", :id => false, :force => true do |t|
    t.integer "disciplina_id"
    t.integer "disciplina_contratacao_id"
  end

  create_table "distritos", :force => true do |t|
    t.integer  "municipio_id"
    t.string   "nome"
    t.string   "codigo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tipo"
  end

  add_index "distritos", ["municipio_id"], :name => "index_distritos_on_municipio_id"

  create_table "enquetes", :force => true do |t|
    t.string   "tipo"
    t.string   "sujeito"
    t.string   "opiniao_um"
    t.text     "comentario_um"
    t.string   "opiniao_dois"
    t.text     "comentario_dois"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entidade_users", :force => true do |t|
    t.integer  "user_id"
    t.string   "entidades"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entidades", :force => true do |t|
    t.string   "nome"
    t.integer  "esfera_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sigla"
  end

  create_table "escolas", :force => true do |t|
    t.string   "codigo"
    t.string   "nome_da_escola"
    t.string   "tipologia"
    t.string   "rede"
    t.string   "zona"
    t.string   "endereco"
    t.string   "telefone"
    t.string   "fax"
    t.string   "email"
    t.integer  "latitude"
    t.integer  "longitude"
    t.integer  "nae_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "celular"
    t.string   "numero"
    t.string   "complemento"
    t.string   "bairro"
    t.integer  "gt_id"
    t.string   "diretor"
    t.integer  "orgao_id"
    t.integer  "lotacao_id"
    t.string   "cep"
    t.string   "cnpj"
    t.integer  "tipo_destino_id"
    t.integer  "municipio_id"
    t.integer  "esfera_id"
    t.integer  "entidade_id"
    t.string   "slug"
    t.integer  "ano_letivo_id"
    t.string   "nome"
    t.string   "distrito"
  end

  add_index "escolas", ["municipio_id"], :name => "index_escolas_on_municipio_id"
  add_index "escolas", ["orgao_id"], :name => "index_escolas_on_orgao_id"
  add_index "escolas", ["tipo_destino_id"], :name => "index_escolas_on_tipo_destino_id"

  create_table "escolas_matrizes", :id => false, :force => true do |t|
    t.integer "escola_id"
    t.integer "matriz_id"
    t.integer "niveis_ensino_id"
  end

  create_table "esferas", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codigo"
  end

  create_table "especificar_lotacaos", :force => true do |t|
    t.integer  "funcionario_id"
    t.integer  "escola_id"
    t.integer  "turma_id"
    t.integer  "disciplina_id"
    t.integer  "hora_semanal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ativo",          :default => true
    t.integer  "lotacao_id"
    t.integer  "entidade_id"
    t.string   "tipo"
    t.integer  "ambiente_id"
  end

  add_index "especificar_lotacaos", ["funcionario_id"], :name => "index_especificar_lotacaos_on_funcionario_id"

  create_table "estados", :force => true do |t|
    t.string   "nome"
    t.string   "sigla"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "estados", ["nome"], :name => "index_estados_on_nome"
  add_index "estados", ["sigla"], :name => "index_estados_on_sigla"

  create_table "fator_lotacaos", :force => true do |t|
    t.integer  "turma_id"
    t.integer  "fator"
    t.integer  "serie_id"
    t.integer  "disciplina_id"
    t.integer  "especificar_lotacao_id"
    t.integer  "curriculo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  add_index "fator_lotacaos", ["especificar_lotacao_id"], :name => "index_fator_lotacaos_on_especificar_lotacao_id"

  create_table "financeiro_fixos", :force => true do |t|
    t.integer  "competencia_id"
    t.integer  "mes"
    t.integer  "ano"
    t.integer  "evento_id"
    t.float    "valor"
    t.integer  "funcionario_id"
    t.integer  "prazo"
    t.integer  "parametro"
    t.integer  "tipo_parametro_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  create_table "folha_competencias", :force => true do |t|
    t.string   "nome"
    t.string   "motivo"
    t.boolean  "padrao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  create_table "folha_eventos", :force => true do |t|
    t.string   "codigo",          :limit => 6
    t.string   "nome",            :limit => 30
    t.string   "formula"
    t.string   "tipo",            :limit => 1
    t.string   "codigo_contabil", :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.boolean  "ps_ativo",                      :default => false
    t.boolean  "ir_ativo",                      :default => false
    t.boolean  "fg_ativo",                      :default => false
    t.boolean  "dt_ativo",                      :default => false
    t.boolean  "ps_inativo",                    :default => false
    t.boolean  "ir_inativo",                    :default => false
    t.boolean  "dt_inativo",                    :default => false
    t.integer  "sequencia"
    t.string   "intervalo"
  end

  create_table "folha_financeiro_fixos", :force => true do |t|
    t.integer  "evento_id",                                     :null => false
    t.integer  "ano",                                           :null => false
    t.integer  "mes",               :limit => 2,                :null => false
    t.integer  "funcionario_id",                                :null => false
    t.integer  "prazo",                          :default => 0, :null => false
    t.integer  "parametro",                      :default => 0, :null => false
    t.integer  "tipo_parametro_id"
    t.integer  "quantidade",                     :default => 0, :null => false
    t.float    "valor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  add_index "folha_financeiro_fixos", ["evento_id", "funcionario_id", "ano", "mes"], :name => "eventos_fixos_index", :unique => true

  create_table "folha_financeiros", :force => true do |t|
    t.integer  "evento_id",                                     :null => false
    t.integer  "sequencia",                                     :null => false
    t.integer  "ano",                                           :null => false
    t.integer  "mes",                                           :null => false
    t.integer  "funcionario_id",                                :null => false
    t.integer  "prazo",                          :default => 0, :null => false
    t.integer  "parametro",                      :default => 0, :null => false
    t.integer  "tipo_parametro_id"
    t.integer  "quantidade",                     :default => 0, :null => false
    t.float    "valor",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folha_id",                                      :null => false
    t.integer  "entidade_id"
    t.string   "codigo_alt",        :limit => 1
    t.string   "observacao"
  end

  add_index "folha_financeiros", ["evento_id", "funcionario_id", "ano", "mes", "sequencia"], :name => "eventos_variaveis_index", :unique => true

  create_table "folha_folhas", :force => true do |t|
    t.integer  "competencia_id"
    t.integer  "ano"
    t.integer  "mes"
    t.boolean  "padrao",           :default => false
    t.integer  "esfera_id"
    t.integer  "entidade_id"
    t.boolean  "ativa",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fonte_recurso_id"
  end

  create_table "folha_fonte_recursos", :force => true do |t|
    t.string   "nome"
    t.integer  "esfera_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codigo"
  end

  create_table "formacaos", :force => true do |t|
    t.integer  "pessoa_id"
    t.string   "curso"
    t.string   "titulacao"
    t.string   "habilitacao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ano_de_inicio",        :limit => nil
    t.string   "ano_de_termino",       :limit => nil
    t.string   "instituicao"
    t.string   "tipo"
    t.string   "status"
    t.string   "data_obtencao_titulo"
    t.string   "titulo_dissertacao"
    t.string   "nome_orientador"
    t.integer  "nivel_id"
    t.integer  "titulo_id"
    t.integer  "subtipo_id"
    t.integer  "carga_horaria"
    t.boolean  "verificado",                          :default => false
    t.boolean  "principal",                           :default => false
  end

  add_index "formacaos", ["pessoa_id"], :name => "index_formacaos_on_pessoa_id"

  create_table "fotos", :force => true do |t|
    t.integer  "pessoa_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "imagem_file_name"
    t.string   "imagem_content_type"
    t.integer  "imagem_file_size"
    t.datetime "imagem_updated_at"
    t.integer  "entidade_id"
  end

  create_table "funcionarios", :force => true do |t|
    t.integer  "pessoa_id"
    t.string   "matricula"
    t.string   "cpf"
    t.string   "cargo_nome"
    t.integer  "cargo_id"
    t.string   "funcao"
    t.string   "orgao_id"
    t.integer  "nivel_id"
    t.string   "jornada"
    t.string   "classe"
    t.string   "decreto_nomeacao"
    t.date     "data_nomeacao"
    t.string   "termo_posse"
    t.integer  "comissao_id"
    t.string   "afastamento"
    t.string   "funcao_gratificada"
    t.string   "situacao_juridica"
    t.string   "banco"
    t.string   "agencia"
    t.string   "conta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cargo"
    t.string   "nivel"
    t.integer  "sjuridica_id"
    t.integer  "quadro_id"
    t.integer  "disciplina_contratacao_id"
    t.integer  "folha_id"
    t.integer  "municipio_id"
    t.integer  "distrito_id"
    t.boolean  "recad"
    t.string   "gaveta"
    t.text     "observacao"
    t.integer  "recad_cargo_id"
    t.string   "lotacao_recad"
    t.boolean  "licenca"
    t.integer  "escola_id"
    t.boolean  "verificado"
    t.integer  "arquivo_id"
    t.integer  "categoria_ids"
    t.integer  "categoria_id"
    t.boolean  "cargo_em_comissao"
    t.string   "decreto_nomeacao_comissao"
    t.date     "data_decreto_nomeacao"
    t.string   "decreto_exoneracao_comissao"
    t.date     "data_decreto_exoneracao"
    t.string   "tipo_comissionado"
    t.string   "tipo_comissao"
    t.boolean  "comissao_ativa"
    t.float    "vencimento"
    t.integer  "entidade_id"
    t.string   "slug"
    t.integer  "fonte_recurso_id"
    t.string   "codigo_sirh"
    t.string   "conjunto"
    t.integer  "usuario_id"
    t.boolean  "interiorizacao",              :default => false
    t.integer  "interiorizacao_valor"
    t.integer  "interiorizacao_rubrica"
    t.boolean  "ativo",                       :default => true
  end

  add_index "funcionarios", ["cargo_id"], :name => "index_funcionarios_on_cargo_id"
  add_index "funcionarios", ["categoria_id"], :name => "index_funcionarios_on_categoria_id"
  add_index "funcionarios", ["disciplina_contratacao_id"], :name => "index_funcionarios_on_descricao_cargo_id"
  add_index "funcionarios", ["distrito_id"], :name => "index_funcionarios_on_distrito_id"
  add_index "funcionarios", ["escola_id"], :name => "index_funcionarios_on_escola_id"
  add_index "funcionarios", ["folha_id"], :name => "index_funcionarios_on_folha_id"
  add_index "funcionarios", ["municipio_id"], :name => "index_funcionarios_on_municipio_id"
  add_index "funcionarios", ["nivel_id"], :name => "index_funcionarios_on_nivel_id"
  add_index "funcionarios", ["orgao_id"], :name => "index_funcionarios_on_orgao_id"
  add_index "funcionarios", ["pessoa_id"], :name => "index_funcionarios_on_pessoa_id"
  add_index "funcionarios", ["quadro_id"], :name => "index_funcionarios_on_quadro_id"
  add_index "funcionarios", ["sjuridica_id"], :name => "index_funcionarios_on_sjuridica_id"
  add_index "funcionarios", ["slug"], :name => "index_funcionarios_on_slug", :unique => true

  create_table "funcionarios_gratificacoes", :id => false, :force => true do |t|
    t.integer "funcionario_id"
    t.integer "gratificacao_id"
  end

  create_table "gratificacoes", :force => true do |t|
    t.string   "nome"
    t.string   "codigo"
    t.integer  "valor_fixo"
    t.integer  "valor_porcentagem"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rubrica_id"
    t.integer  "funcionario_id"
  end

  create_table "grupo_educacionais", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listas", :force => true do |t|
    t.integer  "funcionario_id"
    t.integer  "pessoa_id"
    t.date     "data_inclusao"
    t.integer  "tipo_lista_id"
    t.text     "motivo"
    t.boolean  "ativo",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  add_index "listas", ["funcionario_id"], :name => "index_listas_on_funcionario_id"
  add_index "listas", ["pessoa_id"], :name => "index_listas_on_pessoa_id"
  add_index "listas", ["tipo_lista_id"], :name => "index_listas_on_tipo_lista_id"

  create_table "lotacaos", :force => true do |t|
    t.integer  "funcionario_id"
    t.integer  "escola_id"
    t.integer  "carga_horaria_disponivel"
    t.date     "data_lotacao"
    t.boolean  "regencia_de_classe"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finalizada",                             :default => false
    t.string   "codigo_barra"
    t.boolean  "ativo",                                  :default => true
    t.string   "tipo_lotacao",             :limit => 20
    t.integer  "orgao_id"
    t.integer  "esfera_id"
    t.integer  "tipo_destino_id"
    t.integer  "departamento_id"
    t.integer  "unidade_id"
    t.boolean  "convalidada",                            :default => false
    t.datetime "data_convalidacao"
    t.integer  "convalidador_id"
    t.integer  "entidade_id"
    t.boolean  "complementar",                           :default => false
    t.integer  "ambiente_id"
    t.date     "data_confirmacao"
    t.boolean  "quick",                                  :default => false
    t.text     "motivo"
    t.integer  "usuario_id"
    t.integer  "disciplina_atuacao_id"
    t.integer  "destino_id"
    t.string   "destino_type"
    t.string   "state"
    t.integer  "contrato_id"
  end

  add_index "lotacaos", ["departamento_id"], :name => "index_lotacaos_on_departamento_id"
  add_index "lotacaos", ["escola_id"], :name => "index_lotacaos_on_escola_id"
  add_index "lotacaos", ["funcionario_id"], :name => "index_lotacaos_on_funcionario_id"
  add_index "lotacaos", ["orgao_id"], :name => "index_lotacaos_on_orgao_id"

  create_table "manutencoes", :force => true do |t|
    t.integer  "tempo"
    t.string   "tipo"
    t.boolean  "em_manutencao"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matrizes", :force => true do |t|
    t.string   "codigo"
    t.string   "modalidade"
    t.integer  "dias_letivos_anuais"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.integer  "dias_letivos_semanais"
    t.integer  "semanas_letivas"
    t.integer  "modulo_aula"
    t.integer  "carga_horaria_anual"
    t.integer  "nivel_id"
    t.string   "nome"
  end

  create_table "mensagens", :force => true do |t|
    t.integer  "usuario_id"
    t.integer  "destinatario_id"
    t.text     "texto"
    t.boolean  "aviso",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tipo"
  end

  create_table "municipios", :force => true do |t|
    t.string   "nome"
    t.string   "cep"
    t.string   "sigla"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "municipios", ["cep"], :name => "index_municipios_on_cep"
  add_index "municipios", ["nome"], :name => "index_municipios_on_nome"
  add_index "municipios", ["sigla"], :name => "index_municipios_on_sigla"

  create_table "naturezas", :force => true do |t|
    t.string   "nome"
    t.boolean  "ativo",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "naturezas_listas", :id => false, :force => true do |t|
    t.integer "natureza_id"
    t.integer "tipo_listum_id_id"
  end

  create_table "niveis", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordem",      :default => 0
  end

  create_table "niveis_ensinos", :force => true do |t|
    t.string   "nome"
    t.string   "codigo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nivel_cargos", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orgaos", :force => true do |t|
    t.string   "codigo"
    t.string   "nome"
    t.string   "sigla"
    t.integer  "responsavel_id"
    t.string   "telefone"
    t.string   "endereco"
    t.string   "numero"
    t.string   "complemento"
    t.string   "grupo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.integer  "esfera_id"
    t.integer  "poder_id"
    t.integer  "tipo_administracao_id"
    t.integer  "municipio_id"
  end

  add_index "orgaos", ["esfera_id"], :name => "index_orgaos_on_esfera_id"
  add_index "orgaos", ["poder_id"], :name => "index_orgaos_on_poder_id"
  add_index "orgaos", ["tipo_administracao_id"], :name => "index_orgaos_on_tipo_administracao_id"

  create_table "periodos", :force => true do |t|
    t.date     "inicio"
    t.date     "fim"
    t.datetime "abertura"
    t.datetime "encerramento"
    t.string   "status"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "pessoas", :force => true do |t|
    t.string   "nome"
    t.string   "sexo"
    t.string   "endereco"
    t.string   "numero"
    t.string   "complemento"
    t.string   "bairro"
    t.string   "telefone_residencial"
    t.string   "telefone_celular"
    t.date     "nascimento"
    t.string   "naturalidade"
    t.string   "nacionalidade"
    t.string   "cpf"
    t.string   "rg"
    t.string   "pis_pasep"
    t.integer  "cidade_id"
    t.string   "uf"
    t.integer  "dep_ir"
    t.integer  "dep_sf"
    t.integer  "ano_de_chegada"
    t.string   "estado_civil"
    t.string   "escolaridade"
    t.string   "titulo_eleitor"
    t.string   "zona_eleitoral"
    t.string   "secao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cep"
    t.string   "email"
    t.integer  "entidade_id"
    t.string   "slug"
    t.string   "pai"
    t.string   "mae"
    t.string   "conjunto"
    t.integer  "usuario_id"
    t.boolean  "verificado"
  end

  add_index "pessoas", ["slug"], :name => "index_pessoas_on_slug", :unique => true

  create_table "poders", :force => true do |t|
    t.string   "codigo"
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ponto_assinaturas", :force => true do |t|
    t.string   "ip_assinatura"
    t.integer  "ponto_diario_id"
    t.datetime "data_assinatura"
    t.boolean  "assinado",        :default => false
    t.boolean  "valido",          :default => false
    t.integer  "evento_id"
    t.string   "tipo"
    t.integer  "dia"
    t.integer  "mes"
    t.integer  "ano"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  create_table "ponto_diarios", :force => true do |t|
    t.string   "ip_assinatura"
    t.datetime "data_assinatura"
    t.integer  "user_id"
    t.integer  "pessoa_id"
    t.integer  "funcionario_id"
    t.integer  "ponto_id"
    t.boolean  "assinado"
    t.boolean  "false"
    t.boolean  "valido"
    t.integer  "evento_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

  create_table "pontos", :force => true do |t|
    t.integer  "entidade_id"
    t.integer  "funcionario_id"
    t.integer  "lotacao_id"
    t.date     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codigo_barras"
    t.boolean  "verificado",      :default => false
    t.boolean  "valido",          :default => false
    t.integer  "comissionado_id"
    t.integer  "usuario_id"
    t.integer  "arquivo_ponto"
    t.integer  "arquivo_codigo"
  end

  create_table "processos", :force => true do |t|
    t.string   "processo"
    t.string   "natureza"
    t.integer  "ano_processo"
    t.integer  "pessoa_id"
    t.integer  "funcionario_id"
    t.integer  "destino_id"
    t.boolean  "regencia_classe"
    t.datetime "encaminhado_em"
    t.integer  "substituto_id"
    t.integer  "temporalidade"
    t.integer  "status_id"
    t.datetime "lotado_em"
    t.text     "observacao"
    t.integer  "responsavelcriacao_id"
    t.integer  "responsavelfinal_id"
    t.boolean  "finalizado",                  :default => false
    t.datetime "data_finalizado"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lotacao_id"
    t.string   "tipo"
    t.string   "decreto_nomeacao_comissao"
    t.date     "data_decreto_nomeacao"
    t.date     "data_decreto_exoneracao"
    t.string   "decreto_exoneracao_comissao"
    t.integer  "entidade_id"
  end

  add_index "processos", ["funcionario_id"], :name => "index_processos_on_funcionario_id"
  add_index "processos", ["pessoa_id"], :name => "index_processos_on_pessoa_id"
  add_index "processos", ["processo"], :name => "index_processos_on_processo"
  add_index "processos", ["status_id"], :name => "index_processos_on_status_id"

  create_table "quadros", :force => true do |t|
    t.string   "codigo"
    t.string   "nome"
    t.string   "esfera_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poder_id"
    t.string   "lei"
    t.date     "data_lei"
    t.integer  "entidade_id"
  end

  add_index "quadros", ["esfera_id"], :name => "index_quadros_on_esfera_id"
  add_index "quadros", ["poder_id"], :name => "index_quadros_on_poder_id"

  create_table "recad_cargos", :force => true do |t|
    t.string   "matricula"
    t.integer  "pessoa_id"
    t.integer  "user_id"
    t.date     "data_nomeacao"
    t.string   "classe"
    t.string   "situacao_funcional"
    t.boolean  "licenca"
    t.string   "tipo_licenca"
    t.integer  "orgao_id"
    t.integer  "cargo_id"
    t.string   "setor_lotacao"
    t.string   "localizacao"
    t.string   "escola_lotacao"
    t.string   "municipio"
    t.string   "decreto_nomeacao"
    t.string   "posto_graduacao"
    t.string   "telefone_orgao"
    t.boolean  "cedido"
    t.string   "orgao_cedido"
    t.boolean  "disposicao"
    t.string   "orgao_disposicao"
    t.integer  "escola_id"
    t.string   "banco"
    t.string   "agencia"
    t.string   "conta_corrente"
    t.boolean  "salvo"
    t.boolean  "valido"
    t.boolean  "regencia_de_classe"
    t.boolean  "cargo_comissionado"
    t.string   "nome_cargo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "descricao_funcao"
    t.string   "comissionado"
    t.integer  "quadro_id"
    t.string   "bg_inclusao"
    t.string   "nome_de_guerra"
    t.date     "data_de_inclusao"
    t.string   "lotacao_atual"
  end

  add_index "recad_cargos", ["matricula"], :name => "index_recad_cargos_on_matricula"
  add_index "recad_cargos", ["pessoa_id"], :name => "index_recad_cargos_on_pessoa_id"
  add_index "recad_cargos", ["user_id"], :name => "index_recad_cargos_on_user_id"

  create_table "recad_escolaridades", :force => true do |t|
    t.string   "nivel"
    t.string   "estado"
    t.date     "data_inicio"
    t.date     "data_conclusao"
    t.string   "instituicao"
    t.string   "curso"
    t.text     "observacao"
    t.integer  "pessoa_id"
    t.integer  "user_id"
    t.boolean  "salvo"
    t.boolean  "valido"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recad_pessoas", :force => true do |t|
    t.string   "cpf"
    t.string   "nome"
    t.date     "data_de_nascimento"
    t.string   "sexo"
    t.string   "estado_civil"
    t.string   "nacionalidade"
    t.string   "naturalidade"
    t.string   "rg"
    t.string   "orgao_expedidor_rg"
    t.date     "data_emissao_rg"
    t.string   "pis_pasep"
    t.string   "situacao_militar"
    t.string   "nome_da_mae"
    t.string   "nome_do_pai"
    t.string   "titulo_eleitor"
    t.string   "zona"
    t.string   "secao"
    t.string   "numero_de_registro"
    t.string   "conselho"
    t.string   "telefone"
    t.string   "celular"
    t.string   "email"
    t.string   "endereco_residencial"
    t.string   "numero"
    t.string   "bairro"
    t.integer  "estado_id"
    t.integer  "cidade_id"
    t.string   "cep"
    t.string   "complemento"
    t.boolean  "salvo"
    t.integer  "user_id"
    t.string   "cidade_natural"
    t.boolean  "valido"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mais_de_um_cargo",     :default => false
  end

  create_table "recads", :force => true do |t|
    t.string   "nome"
    t.string   "email"
    t.string   "telefone_celular"
    t.string   "telefone_residencial"
    t.string   "endereco_rua"
    t.string   "endereco_numero"
    t.string   "endereco_bairro"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cargo"
    t.string   "vinculo"
    t.string   "gratificacao"
    t.string   "decreto_nomeacao"
    t.string   "data_nomeacao"
    t.string   "diario"
    t.string   "data_diario"
    t.string   "cidade"
    t.string   "estado"
    t.string   "cep"
  end

  create_table "referencia_niveis", :force => true do |t|
    t.string   "nome"
    t.string   "codigo"
    t.integer  "vencimento_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.integer  "jornada"
  end

  add_index "referencia_niveis", ["codigo"], :name => "index_referencia_niveis_on_codigo"
  add_index "referencia_niveis", ["nome"], :name => "index_referencia_niveis_on_nome"

  create_table "requisicoes", :force => true do |t|
    t.integer  "funcionario_id"
    t.string   "tipo_requisicao"
    t.integer  "periodo_id"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "lotacao_type"
    t.integer  "lotacao_id"
    t.string   "ambiente"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fullname"
    t.string   "description"
    t.integer  "entidade_id"
  end

  create_table "roles_tipo_listas", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "tipo_lista_id"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id"
  add_index "roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id"

  create_table "rubricas", :force => true do |t|
    t.string   "nome"
    t.integer  "codigo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", :force => true do |t|
    t.string   "nome"
    t.string   "codigo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.integer  "nivel_id"
  end

  create_table "sessions", :force => true do |t|
    t.text     "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer  "escola_id"
    t.integer  "objeto_id"
    t.string   "tipo_config"
    t.boolean  "ativo",              :default => true
    t.integer  "temporalidade"
    t.string   "tipo_temporalidade"
    t.boolean  "finalizado",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "data"
    t.integer  "entidade_id"
    t.integer  "ano_letivo_id"
  end

  add_index "settings", ["escola_id"], :name => "index_settings_on_escola_id"
  add_index "settings", ["objeto_id"], :name => "index_settings_on_objeto_id"

  create_table "situacoes_juridicas", :force => true do |t|
    t.string   "nome"
    t.string   "sigla"
    t.integer  "evento_previdencia_id"
    t.integer  "evento_vencimento_id"
    t.integer  "evento_tributacao_id"
    t.integer  "exercicio_anual"
    t.integer  "exercicio_mensal"
    t.string   "exercicio_folha"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jornada"
    t.integer  "entidade_id"
  end

  add_index "situacoes_juridicas", ["nome"], :name => "index_situacoes_juridicas_on_nome"
  add_index "situacoes_juridicas", ["sigla"], :name => "index_situacoes_juridicas_on_sigla"

  create_table "statuses", :force => true do |t|
    t.integer  "processo_id"
    t.date     "data"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["processo_id"], :name => "index_statuses_on_processo_id"

  create_table "subtipos", :force => true do |t|
    t.integer  "nivel_id"
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "textos", :force => true do |t|
    t.string   "nome"
    t.text     "texto"
    t.integer  "categoria_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tipo"
  end

  create_table "tipo_administracaos", :force => true do |t|
    t.string   "codigo"
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tipo_ambientes", :force => true do |t|
    t.string   "nome"
    t.string   "tipo_especificacao", :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tipo_destinos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nome"
    t.string   "tipo",       :limit => 20
  end

  create_table "tipo_lista", :force => true do |t|
    t.string   "nome"
    t.integer  "peso"
    t.boolean  "ativo",                :default => true
    t.string   "tipo_objeto"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "arquivo_file_name"
    t.string   "arquivo_content_type"
    t.integer  "arquivo_file_size"
    t.datetime "arquivo_updated_at"
    t.integer  "entidade_id"
    t.boolean  "privada",              :default => false
  end

  create_table "tipos", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "titulos", :force => true do |t|
    t.string   "nome"
    t.integer  "nivel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "turmas", :force => true do |t|
    t.integer  "ambiente_id"
    t.integer  "matriz_id"
    t.integer  "serie_id"
    t.string   "turno"
    t.integer  "escola_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
    t.string   "nome"
    t.integer  "ano_letivo_id"
  end

  add_index "turmas", ["ambiente_id"], :name => "index_turmas_on_ambiente_id"
  add_index "turmas", ["escola_id"], :name => "index_turmas_on_escola_id"
  add_index "turmas", ["matriz_id"], :name => "index_turmas_on_matrize_id"
  add_index "turmas", ["serie_id"], :name => "index_turmas_on_serie_id"

  create_table "turnos", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                      :default => "",    :null => false
    t.string   "encrypted_password",          :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "name"
    t.integer  "roles_mask"
    t.integer  "orgao_id"
    t.integer  "departamento_id"
    t.integer  "entidade_id"
    t.boolean  "enabled",                                    :default => false
    t.integer  "escola_id"
    t.integer  "funcionario_id"
    t.boolean  "gerar_ponto",                                :default => false, :null => false
    t.string   "unidade_organizacional_type"
    t.integer  "unidade_organizacional_id"
    t.string   "tipo_uo"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_entidades", :id => false, :force => true do |t|
    t.integer "entidade_id"
    t.integer "user_id"
  end

  create_table "usuarios", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "vencimentos", :force => true do |t|
    t.integer  "referencia_nivel_id",                                :null => false
    t.integer  "ano",                                                :null => false
    t.integer  "mes",                 :limit => 2,                   :null => false
    t.float    "valor",                                              :null => false
    t.boolean  "atual",                            :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entidade_id"
  end

end
