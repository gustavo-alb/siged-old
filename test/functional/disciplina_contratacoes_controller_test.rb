require 'test_helper'

class DisciplinaContratacoesControllerTest < ActionController::TestCase
  setup do
    @disciplina_contratacao = disciplina_contratacoes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:disciplina_contratacoes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create disciplina_contratacao" do
    assert_difference('DisciplinaContratacao.count') do
      post :create, disciplina_contratacao: @disciplina_contratacao.attributes
    end

    assert_redirected_to disciplina_contratacao_path(assigns(:disciplina_contratacao))
  end

  test "should show disciplina_contratacao" do
    get :show, id: @disciplina_contratacao
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @disciplina_contratacao
    assert_response :success
  end

  test "should update disciplina_contratacao" do
    put :update, id: @disciplina_contratacao, disciplina_contratacao: @disciplina_contratacao.attributes
    assert_redirected_to disciplina_contratacao_path(assigns(:disciplina_contratacao))
  end

  test "should destroy disciplina_contratacao" do
    assert_difference('DisciplinaContratacao.count', -1) do
      delete :destroy, id: @disciplina_contratacao
    end

    assert_redirected_to disciplina_contratacoes_path
  end
end
