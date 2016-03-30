require 'test_helper'

class SituacoesControllerTest < ActionController::TestCase
  setup do
    @situacao = situacoes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:situacoes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create situacao" do
    assert_difference('Situacao.count') do
      post :create, situacao: { cor: @situacao.cor, nome: @situacao.nome }
    end

    assert_redirected_to situacao_path(assigns(:situacao))
  end

  test "should show situacao" do
    get :show, id: @situacao
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @situacao
    assert_response :success
  end

  test "should update situacao" do
    put :update, id: @situacao, situacao: { cor: @situacao.cor, nome: @situacao.nome }
    assert_redirected_to situacao_path(assigns(:situacao))
  end

  test "should destroy situacao" do
    assert_difference('Situacao.count', -1) do
      delete :destroy, id: @situacao
    end

    assert_redirected_to situacoes_path
  end
end
