require File.dirname(__FILE__) + '/../../../test_helper'

class Admin::Organizations::ContactsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admin/organizations_contacts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_contacts
    assert_difference('Admin::Organizations::Contacts.count') do
      post :create, :contacts => { }
    end

    assert_redirected_to contacts_path(assigns(:contacts))
  end

  def test_should_show_contacts
    get :show, :id => admin/organizations_contacts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admin/organizations_contacts(:one).id
    assert_response :success
  end

  def test_should_update_contacts
    put :update, :id => admin/organizations_contacts(:one).id, :contacts => { }
    assert_redirected_to contacts_path(assigns(:contacts))
  end

  def test_should_destroy_contacts
    assert_difference('Admin::Organizations::Contacts.count', -1) do
      delete :destroy, :id => admin/organizations_contacts(:one).id
    end

    assert_redirected_to admin/organizations_contacts_path
  end
end
