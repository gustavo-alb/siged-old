require 'test_helper'

class OrgoesControllerTest < ActionController::TestCase
  setup do
    @orgao = orgoes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orgoes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create orgao" do
    assert_difference('Orgao.count') do
      post :create, orgao: @orgao.attributes
    end

    assert_redirected_to orgao_path(assigns(:orgao))
  end

  test "should show orgao" do
    get :show, id: @orgao
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @orgao
    assert_response :success
  end

  test "should update orgao" do
    put :update, id: @orgao, orgao: @orgao.attributes
    assert_redirected_to orgao_path(assigns(:orgao))
  end

  test "should destroy orgao" do
    assert_difference('Orgao.count', -1) do
      delete :destroy, id: @orgao
    end

    assert_redirected_to orgoes_path
  end
end
