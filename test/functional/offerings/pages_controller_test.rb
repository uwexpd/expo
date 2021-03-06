require File.dirname(__FILE__) + '/../../test_helper'

class Offerings::PagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:offerings_pages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_page
    assert_difference('Offerings::Page.count') do
      post :create, :page => { }
    end

    assert_redirected_to page_path(assigns(:page))
  end

  def test_should_show_page
    get :show, :id => offerings_pages(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => offerings_pages(:one).id
    assert_response :success
  end

  def test_should_update_page
    put :update, :id => offerings_pages(:one).id, :page => { }
    assert_redirected_to page_path(assigns(:page))
  end

  def test_should_destroy_page
    assert_difference('Offerings::Page.count', -1) do
      delete :destroy, :id => offerings_pages(:one).id
    end

    assert_redirected_to offerings_pages_path
  end
end
