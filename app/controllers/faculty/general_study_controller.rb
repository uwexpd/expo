class Faculty::GeneralStudyController < FacultyController
  before_filter :add_general_study_breadcrumbs
  before_filter :fetch_quarter, :fetch_course, :fetch_students
  
  def index
    session[:breadcrumbs].add "Home"
  end

  def students
    session[:breadcrumbs].add "Students"
  end
    
  def general_study_approval
    @self_placement = ServiceLearningSelfPlacement.find(params[:id])
    
    if @self_placement.nil?
      flash[:error] = "Can not find the student's general study position."
      redirect_to :action => :students and return
    end    
    
    flash.now[:notice] = "This position has been approved already." if  @self_placement.faculty_approved?
    
    if request.put?
        @self_placement.submitted = params[:service_learning_self_placement][:faculty_approved]=="false" ? false : true
      if @self_placement.save && @self_placement.update_attributes(params[:service_learning_self_placement])
          if @self_placement.faculty_approved?
              flash[:notice] = "You successfully approved #{@self_placement.position.name} for #{@self_placement.person.fullname} . Thank you."
          else
              template = EmailTemplate.find_by_name("general study request decline by facutly")
              TemplateMailer.deliver(template.create_email_to(@self_placement, 
                                                              "http://#{CONSTANTS[:base_url_host]}/service_learning/general_study",
                                                              @self_placement.person.email)
                                    ) if template            
              flash[:notice] = "You declined the general sutdy position request for #{@self_placement.person.fullname}. A email with your feedback sent to the student."
          end
      end      
      redirect_to :action => :students
    end    
    session[:breadcrumbs].add "Students", faculty_general_study_path(:action => 'students')
    session[:breadcrumbs].add "View General Study Positions"
  end
    

  def evaluation
     @placement = ServiceLearningPlacement.find(params[:id])
     @evaluation = @placement.evaluation || @placement.create_evaluation
     session[:breadcrumbs].add "Students", faculty_general_study_path(:action => 'students')
     session[:breadcrumbs].add "View Evaluation"
   end

  protected
  
  def add_general_study_breadcrumbs
    session[:breadcrumbs].add "General Study", faculty_general_study_home_path(nil)
  end
  
  def fetch_quarter
    @quarter = params[:quarter_abbrev].nil? ? Quarter.current_quarter : Quarter.find_by_abbrev(params[:quarter_abbrev])
    @show_quarter_select_dropdown = true
    session[:breadcrumbs].add @quarter.title, faculty_general_study_home_path(@quarter), :class => 'quarter_select'
  end
  
  def fetch_course
    @general_study_course = @person.service_learning_courses.for(@quarter).detect{|c| c.general_study? }
    if @general_study_course.nil?
      raise ExpoException.new("You are not listed as a General Study faculty",  "If you believe this to be an
            error, please contact the Carlson Center staff.") 
    end    
  end
  
  def fetch_students
    @faculty_students = ServiceLearningSelfPlacement.find_all_by_faculty_person_id(@person).select{|s|s.submitted? || s.faculty_approved?}
  end
  
end
