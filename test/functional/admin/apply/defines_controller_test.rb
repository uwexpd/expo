require 'test_helper'

class Admin::Apply::DefinesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admin/apply_defines)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_define
    assert_difference('Admin::Apply::Define.count') do
      post :create, :define => { }
    end

    assert_redirected_to define_path(assigns(:define))
  end

  def test_should_show_define
    get :show, :id => admin/apply_defines(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admin/apply_defines(:one).id
    assert_response :success
  end

  def test_should_update_define
    put :update, :id => admin/apply_defines(:one).id, :define => { }
    assert_redirected_to define_path(assigns(:define))
  end

  def test_should_destroy_define
    assert_difference('Admin::Apply::Define.count', -1) do
      delete :destroy, :id => admin/apply_defines(:one).id
    end

    assert_redirected_to admin/apply_defines_path
  end
end
