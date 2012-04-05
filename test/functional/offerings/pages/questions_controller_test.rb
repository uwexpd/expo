require File.dirname(__FILE__) + '/../../../test_helper'

class Offerings::Pages::QuestionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:offerings/pages_questions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_question
    assert_difference('Offerings::Pages::Question.count') do
      post :create, :question => { }
    end

    assert_redirected_to question_path(assigns(:question))
  end

  def test_should_show_question
    get :show, :id => offerings/pages_questions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => offerings/pages_questions(:one).id
    assert_response :success
  end

  def test_should_update_question
    put :update, :id => offerings/pages_questions(:one).id, :question => { }
    assert_redirected_to question_path(assigns(:question))
  end

  def test_should_destroy_question
    assert_difference('Offerings::Pages::Question.count', -1) do
      delete :destroy, :id => offerings/pages_questions(:one).id
    end

    assert_redirected_to offerings/pages_questions_path
  end
end
