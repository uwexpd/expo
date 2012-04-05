require 'test_helper'

class Admin::Apply::Define::PhasesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admin/apply/define_phases)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_phase
    assert_difference('Admin::Apply::Define::Phase.count') do
      post :create, :phase => { }
    end

    assert_redirected_to phase_path(assigns(:phase))
  end

  def test_should_show_phase
    get :show, :id => admin/apply/define_phases(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admin/apply/define_phases(:one).id
    assert_response :success
  end

  def test_should_update_phase
    put :update, :id => admin/apply/define_phases(:one).id, :phase => { }
    assert_redirected_to phase_path(assigns(:phase))
  end

  def test_should_destroy_phase
    assert_difference('Admin::Apply::Define::Phase.count', -1) do
      delete :destroy, :id => admin/apply/define_phases(:one).id
    end

    assert_redirected_to admin/apply/define_phases_path
  end
end
