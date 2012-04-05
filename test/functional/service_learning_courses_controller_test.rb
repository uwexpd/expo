require File.dirname(__FILE__) + '/../test_helper'

class ServiceLearningCoursesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:service_learning_courses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_service_learning_course
    assert_difference('ServiceLearningCourse.count') do
      post :create, :service_learning_course => { }
    end

    assert_redirected_to service_learning_course_path(assigns(:service_learning_course))
  end

  def test_should_show_service_learning_course
    get :show, :id => service_learning_courses(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => service_learning_courses(:one).id
    assert_response :success
  end

  def test_should_update_service_learning_course
    put :update, :id => service_learning_courses(:one).id, :service_learning_course => { }
    assert_redirected_to service_learning_course_path(assigns(:service_learning_course))
  end

  def test_should_destroy_service_learning_course
    assert_difference('ServiceLearningCourse.count', -1) do
      delete :destroy, :id => service_learning_courses(:one).id
    end

    assert_redirected_to service_learning_courses_path
  end
end
