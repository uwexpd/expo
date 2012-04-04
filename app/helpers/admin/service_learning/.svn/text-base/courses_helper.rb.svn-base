module Admin::ServiceLearning::CoursesHelper

  def add_course_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :courses, :partial => 'course', :object => ServiceLearningCourseCourse.new
    end
  end

end