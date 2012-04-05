require File.dirname(__FILE__) + '/../test_helper'

class ServiceLearningPositionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:service_learning_positions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_service_learning_position
    assert_difference('ServiceLearningPosition.count') do
      post :create, :service_learning_position => { }
    end

    assert_redirected_to service_learning_position_path(assigns(:service_learning_position))
  end

  def test_should_show_service_learning_position
    get :show, :id => service_learning_positions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => service_learning_positions(:one).id
    assert_response :success
  end

  def test_should_update_service_learning_position
    put :update, :id => service_learning_positions(:one).id, :service_learning_position => { }
    assert_redirected_to service_learning_position_path(assigns(:service_learning_position))
  end

  def test_should_destroy_service_learning_position
    assert_difference('ServiceLearningPosition.count', -1) do
      delete :destroy, :id => service_learning_positions(:one).id
    end

    assert_redirected_to service_learning_positions_path
  end
end
