# Handles the updating of the ServiceLearningCourse.students field
class ServiceLearningCourseSweeper < ActiveRecord::Base

  self.abstract_class = true
  
  # Rebuilds the students field of the ServiceLearningCourse
  # Can pass in a singe Quarter or an array of Quarters they will both work
  # Format: {Student.id=>{:course_id=>ServiceLearningCourseCourse.id}}
  def self.update_students(quarter = Quarter.current_quarter)
    for service_learning_course in ServiceLearningCourse.find_all_by_quarter_id quarter
      students_hash = {}
      for course in service_learning_course.courses
        for student in course.course.all_enrollees
          students_hash[student.id] = {:course_id => course.id}
        end
      end
      for student in service_learning_course.extra_enrollees
        students_hash[student.id] = {}
      end
      service_learning_course.students = students_hash
      service_learning_course.save
    end
    service_learning_courses
  end
end