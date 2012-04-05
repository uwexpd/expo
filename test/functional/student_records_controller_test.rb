require File.dirname(__FILE__) + '/../test_helper'

class StudentRecordsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:student_records)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_student_record
    assert_difference('StudentRecord.count') do
      post :create, :student_record => { }
    end

    assert_redirected_to student_record_path(assigns(:student_record))
  end

  def test_should_show_student_record
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_student_record
    put :update, :id => 1, :student_record => { }
    assert_redirected_to student_record_path(assigns(:student_record))
  end

  def test_should_destroy_student_record
    assert_difference('StudentRecord.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to student_records_path
  end
end
