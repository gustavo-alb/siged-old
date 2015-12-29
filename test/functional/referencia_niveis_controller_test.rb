require 'test_helper'

class ReferenciaNiveisControllerTest < ActionController::TestCase
  setup do
    @referencia_nivel = referencia_niveis(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:referencia_niveis)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create referencia_nivel" do
    assert_difference('ReferenciaNivel.count') do
      post :create, referencia_nivel: @referencia_nivel.attributes
    end

    assert_redirected_to referencia_nivel_path(assigns(:referencia_nivel))
  end

  test "should show referencia_nivel" do
    get :show, id: @referencia_nivel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @referencia_nivel
    assert_response :success
  end

  test "should update referencia_nivel" do
    put :update, id: @referencia_nivel, referencia_nivel: @referencia_nivel.attributes
    assert_redirected_to referencia_nivel_path(assigns(:referencia_nivel))
  end

  test "should destroy referencia_nivel" do
    assert_difference('ReferenciaNivel.count', -1) do
      delete :destroy, id: @referencia_nivel
    end

    assert_redirected_to referencia_niveis_path
  end
end
