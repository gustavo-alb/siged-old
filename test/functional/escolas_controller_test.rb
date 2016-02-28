require 'test_helper'

class EscolasControllerTest < ActionController::TestCase
  setup do
    @escola = escolas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:escolas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create escola" do
    assert_difference('Escola.count') do
      post :create, escola: { ano_letivo_id: @escola.ano_letivo_id, bairro: @escola.bairro, celular: @escola.celular, cep: @escola.cep, cnpj: @escola.cnpj, codigo: @escola.codigo, complemento: @escola.complemento, diretor: @escola.diretor, distrito: @escola.distrito, email: @escola.email, endereco: @escola.endereco, entidade_id: @escola.entidade_id, esfera_id: @escola.esfera_id, fax: @escola.fax, gt_id: @escola.gt_id, lotacao_id: @escola.lotacao_id, municipio_id: @escola.municipio_id, nome: @escola.nome, numero: @escola.numero, orgao_id: @escola.orgao_id, rede: @escola.rede, slug: @escola.slug, telefone: @escola.telefone, tipo_destino_id: @escola.tipo_destino_id, tipologia: @escola.tipologia, zona: @escola.zona }
    end

    assert_redirected_to escola_path(assigns(:escola))
  end

  test "should show escola" do
    get :show, id: @escola
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @escola
    assert_response :success
  end

  test "should update escola" do
    put :update, id: @escola, escola: { ano_letivo_id: @escola.ano_letivo_id, bairro: @escola.bairro, celular: @escola.celular, cep: @escola.cep, cnpj: @escola.cnpj, codigo: @escola.codigo, complemento: @escola.complemento, diretor: @escola.diretor, distrito: @escola.distrito, email: @escola.email, endereco: @escola.endereco, entidade_id: @escola.entidade_id, esfera_id: @escola.esfera_id, fax: @escola.fax, gt_id: @escola.gt_id, lotacao_id: @escola.lotacao_id, municipio_id: @escola.municipio_id, nome: @escola.nome, numero: @escola.numero, orgao_id: @escola.orgao_id, rede: @escola.rede, slug: @escola.slug, telefone: @escola.telefone, tipo_destino_id: @escola.tipo_destino_id, tipologia: @escola.tipologia, zona: @escola.zona }
    assert_redirected_to escola_path(assigns(:escola))
  end

  test "should destroy escola" do
    assert_difference('Escola.count', -1) do
      delete :destroy, id: @escola
    end

    assert_redirected_to escolas_path
  end
end
