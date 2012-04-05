require File.dirname(__FILE__) + '/../../../test_helper'

class CommunityPartner::ServiceLearning::PositionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:community_partner/service_learning_positions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_positions
    assert_difference('CommunityPartner::ServiceLearning::Positions.count') do
      post :create, :positions => { }
    end

    assert_redirected_to positions_path(assigns(:positions))
  end

  def test_should_show_positions
    get :show, :id => community_partner/service_learning_positions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => community_partner/service_learning_positions(:one).id
    assert_response :success
  end

  def test_should_update_positions
    put :update, :id => community_partner/service_learning_positions(:one).id, :positions => { }
    assert_redirected_to positions_path(assigns(:positions))
  end

  def test_should_destroy_positions
    assert_difference('CommunityPartner::ServiceLearning::Positions.count', -1) do
      delete :destroy, :id => community_partner/service_learning_positions(:one).id
    end

    assert_redirected_to community_partner/service_learning_positions_path
  end
end
