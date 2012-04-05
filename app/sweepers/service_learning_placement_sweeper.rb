class ServiceLearningPlacementSweeper < ActionController::Caching::Sweeper
  observe ServiceLearningPlacement
  
  def after_save(placement)
    student = placement.person
    course = placement.course
    quarter = placement.course.quarter_offered rescue nil
    
    if student && course && quarter
      expire_fragment :controller => "Admin::ServiceLearning::Courses",
                      :action => "students",
                      :quarter_abbrev => quarter.abbrev,
                      :id => course,
                      :action_suffix => "student_#{student.id}"
    end                    
                    
  end
  
end