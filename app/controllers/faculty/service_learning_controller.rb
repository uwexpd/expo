class Faculty::ServiceLearningController < FacultyController
  before_filter :add_service_learning_breadcrumbs
  before_filter :fetch_quarter, :fetch_courses
  
  def index
    session[:breadcrumbs].add "Home"
  end

  def positions
    session[:breadcrumbs].add "Positions"
  end

  def students
    session[:breadcrumbs].add "Students"
  end
  
  def position
    @service_learning_position = ServiceLearningPosition.find params[:id]
    session[:breadcrumbs].add "Students", faculty_service_learning_path(:action => 'students')
    session[:breadcrumbs].add "Position"
  end
  
  def organization
    @organization = Organization.find params[:id]
    session[:breadcrumbs].add "Students", faculty_service_learning_path(:action => 'students')
    session[:breadcrumbs].add "Organization"
  end
  
  def potential_organizations    
    session[:breadcrumbs].add "Potential Organizations"
    
    if request.post? || request.put?
      params[:instructor_comments].each do |course_id, quarter_ids|
          instructor = ServiceLearningCourseInstructor.find_by_service_learning_course_id_and_person_id(course_id, @person.id)
          
          quarter_ids.each do |quarter_id, comment|
             if quarter_id.casecmp("overall_comment").zero?
               instructor.update_attribute(:comment, comment) unless comment.blank?
             else
                unless comment.blank?
                  potential_organization_comment =  PotentialCourseOrganizationMatchInstructorComments.find_or_create_by_service_learning_course_instructor_id_and_organization_quarter_id(instructor.id, quarter_id)              
                  potential_organization_comment.update_attribute(:comment, params[:instructor_comments]["#{course_id}"]["#{quarter_id}"])
                end
             end
          end         
      end
      
    end 
    
  end
  
  def edit
    @course = @person.service_learning_courses.find(params[:id])
    session[:breadcrumbs].add "Edit #{@course.title}"
    
    if params[:view] == 'syllabus'
      file_path = File.join(RAILS_ROOT, 'files', @course.syllabus.original.public_path)
      type = @course.syllabus.original.content_type
      disposition = params[:disposition] == 'inline' ? 'inline' : 'attachment'
      send_file file_path, :disposition => disposition, :type => (type || "text") and return unless file_path.nil?
    end
    
    @copy_courses_options = []    
    for service_learning_course in @person.service_learning_courses.sort_by(&:quarter_id).reverse.delete_if{|s|s.id==@course.id}
      key = "#{service_learning_course.title}" + " (#{service_learning_course.quarter.title})"
      value = service_learning_course.id
      @copy_courses_options << [key, value]
    end
      
    if params[:copy_course_id]      
      @copy_course ||= ServiceLearningCourse.find(params[:copy_course_id])
            
      @course.update_attribute(:syllabus, @copy_course.syllabus)
      @course.update_attribute(:syllabus_url, @copy_course.syllabus_url)
      @course.update_attribute(:overview, @copy_course.overview)
      @course.update_attribute(:role_of_service_learning, @copy_course.role_of_service_learning)
      @course.update_attribute(:assignments, @copy_course.assignments)      
    end
        
  end

  def update
    @course = @person.service_learning_courses.find(params[:id])
    if @course.update_attributes(params[:service_learning_course])
      flash[:notice] = "Your course information was successfully updated. Thank you."
      redirect_to faculty_service_learning_home_path(@quarter)
    else
      flash[:error] = "There was a problem updating your course information. Please try again."
      render :action => 'edit'
    end
  end

  def evaluation
    @placement = ServiceLearningPlacement.find(params[:id])
    @evaluation = @placement.evaluation || @placement.create_evaluation
    session[:breadcrumbs].add "Students", faculty_service_learning_path(:action => 'students')
    session[:breadcrumbs].add "View Evaluation"
  end
  
  def self_placement_approval
    @self_placement = ServiceLearningSelfPlacement.find(params[:id])
    
    if @self_placement.nil?
      flash[:error] = "Can not find the student's self placements."
      redirect_to :action => :students and return
    end    
    
    flash.now[:notice] = "This position has been approved already." if  @self_placement.faculty_approved?
    
    if request.put?
        @self_placement.submitted = params[:service_learning_self_placement][:faculty_approved]=="false" ? false : true
      if @self_placement.save && @self_placement.update_attributes(params[:service_learning_self_placement])
          if @self_placement.faculty_approved?
              # template = EmailTemplate.find_by_name("self placement position request for admin approval")
              # TemplateMailer.deliver(template.create_email_to(@self_placement, 
              #                                                 "http://#{CONSTANTS[:base_url_host]}/#{@quarter.abbrev}/self_placements/#{@self_placement.id}",
              #                                                 "serve@u.washington.edu")
              #                       ) if template
              flash[:notice] = "You successfully approved #{@self_placement.position.name} for #{@self_placement.person.fullname} . Thank you."
          else
              template = EmailTemplate.find_by_name("self placement request decline by facutly")
              TemplateMailer.deliver(template.create_email_to(@self_placement, 
                                                              "http://#{CONSTANTS[:base_url_host]}/service_learning/self_placement",
                                                              @self_placement.person.email)
                                    ) if template            
              flash[:notice] = "You declined the self placement request for #{@self_placement.person.fullname}. A email with your feedback sent to the student."
          end
      end      
      redirect_to :action => :students
    end    
    session[:breadcrumbs].add "Students", faculty_service_learning_path(:action => 'students')
    session[:breadcrumbs].add "View Self Placement Positions"
  end
    

  protected
  
  def add_service_learning_breadcrumbs
    session[:breadcrumbs].add "Service-Learning", faculty_service_learning_home_path(nil)
  end
  
  def fetch_quarter
    @quarter = params[:quarter_abbrev].nil? ? Quarter.current_quarter : Quarter.find_by_abbrev(params[:quarter_abbrev])
    @show_quarter_select_dropdown = true
    session[:breadcrumbs].add @quarter.title, faculty_service_learning_home_url(@quarter), :class => 'quarter_select'
  end
  
  def fetch_courses
    @courses = @person.service_learning_courses
    @courses_for_quarter = @person.service_learning_courses.for(@quarter)
    if @courses.empty?
      raise ExpoException.new("You are not listed as an instructor for any service-learning courses.",
            "Our system does not list you as an instructor for any courses in our database. If you believe this to be an
            error, please contact the Carlson Center staff.") 
    end
  end
  
end
