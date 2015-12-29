require 'test_helper'

class MatrizesControllerTest < ActionController::TestCase
  setup do
    @matriz = matrizes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:matrizes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create matriz" do
    assert_difference('Matriz.count') do
      post :create, matriz: @matriz.attributes
    end

    assert_redirected_to matriz_path(assigns(:matriz))
  end

  test "should show matriz" do
    get :show, id: @matriz
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @matriz
    assert_response :success
  end

  test "should update matriz" do
    put :update, id: @matriz, matriz: @matriz.attributes
    assert_redirected_to matriz_path(assigns(:matriz))
  end

  test "should destroy matriz" do
    assert_difference('Matriz.count', -1) do
      delete :destroy, id: @matriz
    end

    assert_redirected_to matrizes_path
  end
end
