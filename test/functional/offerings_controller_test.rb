require File.dirname(__FILE__) + '/../test_helper'

class OfferingsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:offerings)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_offering
    assert_difference('Offering.count') do
      post :create, :offering => { }
    end

    assert_redirected_to offering_path(assigns(:offering))
  end

  def test_should_show_offering
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_offering
    put :update, :id => 1, :offering => { }
    assert_redirected_to offering_path(assigns(:offering))
  end

  def test_should_destroy_offering
    assert_difference('Offering.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to offerings_path
  end
end
