require 'test_helper'

class NiveisEnsinosControllerTest < ActionController::TestCase
  setup do
    @niveis_ensino = niveis_ensinos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:niveis_ensinos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create niveis_ensino" do
    assert_difference('NiveisEnsino.count') do
      post :create, niveis_ensino: @niveis_ensino.attributes
    end

    assert_redirected_to niveis_ensino_path(assigns(:niveis_ensino))
  end

  test "should show niveis_ensino" do
    get :show, id: @niveis_ensino
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @niveis_ensino
    assert_response :success
  end

  test "should update niveis_ensino" do
    put :update, id: @niveis_ensino, niveis_ensino: @niveis_ensino.attributes
    assert_redirected_to niveis_ensino_path(assigns(:niveis_ensino))
  end

  test "should destroy niveis_ensino" do
    assert_difference('NiveisEnsino.count', -1) do
      delete :destroy, id: @niveis_ensino
    end

    assert_redirected_to niveis_ensinos_path
  end
end
