# -*- encoding : utf-8 -*-
Siged20::Application.routes.draw do



  resources :relatorios


  get "contrato/show"

  get "contrato/update"

  resources :situacoes


  resources :escolas do
    get :lotacoes_por_escola,:on=>:collection
    get :relatorios,:on=>:collection
    put "saida_relatorios/:escolas_ids/"=>'escolas#saida_relatorios', as: :saida_relatorios,:on=>:collection
  end


  resources :requisicoes do
    get :definir_funcionario,:on=>:collection
    post :gerar_links,:on=>:collection
    get :requerimento
  end

  resources :requisicoes_admin do
    get :transicionar,:on=>:collection
  end


  resources :carencias do

  end

  namespace :relatorios do
    get "sem_lotacao"
    get "geral"
    get "contrato_docente"
    get "contrato_nao_docente"
    get "seed_anexos"
    get "cargos"
  end

  resources :escolas do
    get :controle_turma
    get :controle_ambiente
    get :listar_turmas
    get :listar_ambientes
    get :incluir_turma
    post :salvar_turma
    get :configuracoes
    get :ctrl_ch_resumido
    get :ctrl_ch_detalhado
    get :gerar_controle_ch
    get :autocomplete_escola_nome, :on => :collection
    resources :ambientes do
      get :configurar_ambiente
      get :configurar_ambiente_fisico
      get :incluir_turma
      post :salvar_turma
      get :excluir_turma
      get :incluir_ambiente_fisico
      post :salvar_ambiente_fisico
      get :excluir_ambiente_fisico
    end
  end

  get 'mensagens/inbox'

  resources :mensagens


  resources :niveis_ensinos do
    resources :series
  end

  resources :enquetes do
    get 'estatisticas_antes'
    get 'estatisticas_depois'
  end

  resources :home, :only=>:index

  namespace :folha do resources :fonte_recursos end
    namespace :arquivo do resources :documentos end
      namespace :administracao do
        resources :migracoes
      end
      resources :categorias do
        resources :textos
      end
      resources :configuracao_pontos
      resources :entidades
      get "administracao/tarefas/funcionarios"
      namespace :administracao do resources :tarefas end
        get "administracao/index"
        get "administracao/atualizar_informacao"
        namespace :folha do resources :competencias end
          namespace :folha do
            resources :financeiros do
              get "validar_matricula"
              get "validar_evento"
            end
          end
          resources :vencimentos
          namespace :folha do
            resources :folhas do
              get "imprimir_financeiros"
              resources :financeiros do

              end
      #fim do resource folhas
    end
    #fim do namespace folha
  end

  resources :pontos do
    get :funcionarios,:on=>:collection
    get :gerar_pontos,:on=>:collection
    post :salvar_pontos,:on=>:collection
  end


  resources :comissionados do
    get "exonerar_comissionado"
    post "salvar_exoneracao"
    resources :pontos do
      get 'gerar_arquivo'
    end
  end

  namespace :folha do resources :eventos end


    resources :categoria

    resources :tipo_listas do
      get :adicionar_de_arquivo
      get :detalhes_pessoa
      post :salvar_arquivo
      get :listar
      get :relatorio
    end

    resources :ambientes


    resources :matrizes do
      get :configurar_curriculos
      put :salvar_curriculo
      resources :curriculos
    end

    resources :settings



    resources :disciplina_contratacoes

    resources :folhas



    resources :quadros do
      resources :folhas
    end

    resources :roles




    devise_for :users
    resources :usuarios

  # add another lines as you need...


  resources :referencia_niveis do
    resources :vencimentos
  end

  resources :situacoes_juridicas

  resources :municipios

  resources :orgaos
  resources :orgaos do
    get 'agenda'
    get 'funcionarios'
    resources :departamentos do
      get :autocomplete_departamento_nome, :on => :collection
      get 'tarefas'
      get 'pontos_funcionarios'
      get 'pontos'
      get 'pontos_do_mes'
      get 'gerar_pontos'
      get 'funcionarios'
      post 'salvar_pontos'
    end
  end



  resources :cargos

  resources :formacoes
  get 'lotacoes/convalidar'
  get 'lotacoes/gerar_relatorio'
  get 'lotacoes/gerar_arquivo'

  get 'relatorios/funcionarios_por_disciplina',:controller=>"funcionarios",:action=>'relatorio_por_disciplina'
  resources :anos_letivos,:controller=>'ano_letivos' do
    get :gerir_carencias
    get :listar_carencias
    put :salvar_carencias
    get :autocomplete_escola_nome,:on=>:collection
    get :autocomplete_disciplina_nome,:on=>:collection
  end

  namespace :contratos do
    get :index
    get :estatisticas
    get :relatorio_nominal
    get :pessoal
    post :funcional
    post :lotacao
    post :revisar
    get :detalhes
    get :editar
    post :salvar
    post :atualizar
    delete :apagar
    get :gerar
    get :relatorio_docente
    get :relatorio_nao_docente
  end

  resources :pessoas do
    member do
      get "contratos_administrativos"
      put 'contrato_novo'
    end
    resources :contrato, only: [:show, :update], controller: 'pessoas/contrato'
    get "dashboard",:on=>:collection
    get "com_pendencias",:on=>:collection
    post 'buscar_cod_barra',:on=>:collection
    get "gerar_relatorio"
    get "nao_lotados",:on=>:collection
    get  "teste_lista_lotacao", :on => :collection
    resources :fotos,:only => [:index, :show, :novo, :create,:new] do
      post 'upload',:on=>:collection
    end
    post "criar_pessoa_contrato", :on=>:collection
    put "cancelar_pessoa_contrato"
    # put 'qualificacao_funcional/:parametro'=>'pessoas#qualificacao_funcional', as: :qualificacao_funcional
    post 'qualificacao_funcional'#=>'pessoas#qualificacao_funcional', as: :qualificacao_funcional
    get "gerar_boletim"
    get "qualificar"
    get "edicao_rapida"
    get "validar_funcionarios"
    post "salvar_boletim"
    get "boletins"
    get "boletim_pessoal"
    get "exibir_boletim"
    get "qualificar_funcionario"
    get "departamento"
    get "adicionar_a_lista"
    post "salvar_lista"
    resources :formacoes
    resources :funcionarios do
      member do
        post :edicao_rapida
      end
      resources :contrato, only: [:show, :update, :gerar_contrato], controller: 'funcionarios/contrato' do
        get 'gerar_contrato'
      end
      post "criar_funcionario_contrato", :on=>:collection
      get "gerar_contrato"
      post :ativar_funcionario
      post :desativar_funcionario
      post :verificar_funcionario
      post :desverificar_funcionario
      resources :comissionados do
        get "exonerar_comissionado"
        post "salvar_exoneracao"
        resources :pontos do
          get 'gerar_arquivo'
        end
      end

      get "boletim_funcional"

      resources :ponto_diarios do

        resources :ponto_assinaturas
        get :assinar_ponto
        post :assinar
      end
      get "historico"
      get "carta"
      get "nova_carta"
      get "gerar_boletim"
      post "salvar_boletim"
      get "boletins"
      get "exibir_boletim"
      resources :lotacoes do

        get "destinos"
        get "devolver_funcionario"
        get "confirmar_lotacao"
        get "cancelar_lotacao"
        get "especificar_lotacao"
        get "especificacao_massiva"
        post "salvar_confirmacao"
        post "salvar_cancelamento"
        post "salvar_devolucao"
        post "salvar_convalidacao"
        post "salvar_especificacao"
        get  "apagar_especificacao"
        # get  "teste_lista_lotacao", :on => :collection
        #get "turmas"
        resources :pontos do
          get 'gerar_arquivo'
        end
      end
    end

  end



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  get 'lotacoes/autocomplete_escola_nome'
  get 'relatorio_sem_categoria',:controller=>"funcionarios",:action=>"relatorio_sem_categoria"
  get 'lotacoes/autocomplete_departamento_nome'
  post 'administracao/tarefas/send_data'
  get 'funcionarios/folha'
  post 'funcionarios/cargo'
  get 'pessoas/naturalidade'
  get 'lotacoes/prolabore'
  get 'lotacoes/especial',:controller=>"lotacoes",:action=>"lotacao_especial"
  get 'lotacoes/destino'
  get 'lotacoes/turmas'
  get 'lotacoes/tipo_destino'
  get 'funcionarios/distrito'
  get 'pessoas/distrito'
  get 'funcionarios/diretor'
  get 'administracao/tarefas/atributos'
  get 'administracao/tarefas/verificar_atributo'
  get 'lotacoes/secretarias',:controller=>"lotacoes",:action=>"escolas_destino"
  get 'folha/financeiro/auto_complete_for_folha_financeiro_funcionario_id',:controller=>"folha/financeiros",:action=>'auto_complete_for_folha_financeiro_funcionario_id'
  get 'folha/financeiro/auto_complete_for_folha_financeiro_evento_id',:controller=>"folha/financeiros",:action=>'auto_complete_for_folha_financeiro_evento_id'
  get 'lotacoes/verifica_lotacao/:funcionario_id', :controller=> 'lotacoes',:action=>"verifica_lotacao"
  # get 'fotos/upload/:pessoa_id', :controller=> 'fotos',:action=>"upload"
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #  get 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  authenticated :user do
    root :to => "home#index",:constraints => lambda{|req| req.env['warden'].user.try(:role?,'lotacao')}, as: :ucolom_root
    root :to => "pessoas#index",:constraints => lambda{|req| req.env['warden'].user.try(:role?,'ucada')}, as: :ucada_root
    root :to => "home#index",:constraints => lambda{|req| req.env['warden'].user.try(:role?,'chefia_ucolom')}, as: :chefia_ucolom_root
    root :to => "contratos#index",:constraints => lambda{|req| req.env['warden'].user.try(:role?,'bancos')}, as: :bancos_root
  end
  root :to => "home#index"


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  get ':controller(/:action(/:id(.:format)))'
end
