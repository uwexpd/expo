class CommunityPartner::ServiceLearning::CoursesController < CommunityPartner::ServiceLearningController
  before_filter :add_courses_breadcrumbs

  def index
  end

  def show
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    session[:breadcrumbs].add @service_learning_course.title
  end

  protected
  
  def add_courses_breadcrumbs
    session[:breadcrumbs].add "Students", community_partner_service_learning_students_path(@quarter)
  end
  

end

