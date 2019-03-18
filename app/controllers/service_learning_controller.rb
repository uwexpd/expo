=begin
  Controls the student service learning registration process.
=end
class ServiceLearningController < ApplicationController
  skip_before_filter :login_required
  before_filter :student_login_required
  before_filter :fetch_quarter
  skip_before_filter :student_login_required, :only => [:test]
  skip_before_filter :check_if_student, :only => [:test]
  before_filter :fetch_student_test, :only => [:test]
  before_filter :check_if_student, :fetch_student, :except => [:test]
  before_filter :fetch_enrolled_service_learning_courses
  before_filter :check_enrolled_service_learning_courses, :except => [:select_non_enrolled_course]
  before_filter :assign_service_learning_course, :except => [:which, :complete]
  before_filter :show_minor_warning, :only => [:index, :position]
  before_filter :require_waiver_if_minor, :only => [:choose, :contact, :risk]
  before_filter :check_if_already_registered, :except => [:complete, :my_position, :which, :test, :self_placement, :self_placement_submit, :general_study, :general_study_submit]
  before_filter :fetch_position, :only => [:position, :choose, :contact, :risk]
  before_filter :check_if_registration_finalized, :only => [:position, :choose, :contact, :risk, :change]
  before_filter :check_if_registration_open, :only => [:choose, :contact, :risk, :change]
  before_filter :check_if_registered_with_same_course, :only => [:self_placement]
  before_filter :fetch_self_placement, :only => [:self_placement, :general_study]


  def index
    session[:type] = nil # clean session so it won't redirect to self_placement action
  end

  def positions
  end

  def position
    @timecodes = @position.times.collect(&:timecodes).flatten
  end

  def which
    if params[:course]
      session[:course] = params[:course]
      if session[:type] == "self_placement"
        redirect_to :action => "self_placement"
      else
        redirect_to :action => "index"
      end
    end
  end
  
  def select_non_enrolled_course
    if params[:course]
      session[:non_enrolled_course] = params[:course]
      redirect_to :action => "index"
    end
  end

  def my_position
    @placements ||= @student.service_learning_placements.for(@quarter,nil).reject{|p|p.position.general_study?}
    redirect_to :action => "index" if @placements.empty?
  end

  def change
    @old_placement = @placements.first
    @old_position = @old_placement.position
    @new_position = ServiceLearningPosition.find params[:id]
    if @new_position.filled_for?(@service_learning_course)
      flash[:error] = "We're sorry, but the new position you selected is no longer available. Please choose another."
      redirect_to :action => "index"
    end
    
    if request.put?
      @old_placement.update_attribute(:person_id, nil)
      # TODO: change place_into to the place_into(position, course, unit) format when the student side it set up to use units
      @student.place_into(@new_position, @service_learning_course)
      flash[:notice] = "You are now registered into your new service-learning position."
      redirect_to :action => "complete"
    end
  end

  def choose
    redirect_to :action => "contact", :id => @position
  end

  def contact
    if request.put?
      if params[:student][:phone].blank?
        @student.errors.add :phone, "cannot be blank."
      else
        @student.update_attribute :phone, params[:student][:phone]
        flash[:notice] = "Contact information saved. Thank you."
        redirect_to :action => "risk", :id => @position
      end
    end
  end

  def risk
    if request.put?
      if params[:student][:electronic_signature].blank?
        @student.errors.add :electronic_signature, "cannot be blank."
      else
        @student.update_attribute :service_learning_risk_signature, params[:student][:electronic_signature]
        @student.update_attribute :service_learning_risk_date, Time.now
        @student.update_attribute :service_learning_risk_date_extention, true if @service_learning_course.unit.abbreviation == 'carlson'
        # TODO: change place_into to the place_into(position, course, unit) format when the student side it set up to use units
        @student.place_into(@position, @service_learning_course)
        flash[:notice] = "Service-learning registration complete."
        redirect_to :action => "complete"
      end
    end
  end

  def complete
    # by specifying nil here, we get placements from all units except pipeline
    @placements ||= @student.service_learning_placements.for(@quarter, nil).reject{|p|p.position.general_study?}
    if !@placements.empty? && @placements.first.position.unit.abbreviation == 'bothell'
      return render :template => 'service_learning/complete_bothell'
    end
  end

  def test
    @service_learning_course.finalized = true
    a = rand(2)
    if a == 0
      render :action => 'index'
    elsif a == 1
      positions = @service_learning_course.positions.reject{|p| p.self_placement? || !p.approved?}
      @position = positions[rand(positions.size-1)]
      return render(:text => "couldn't find a position") unless @position
      @timecodes = @position.times.collect(&:timecodes).flatten
      render :action => 'position'
    end
    flash[:notice] = "Time: #{Time.now - @start_time} seconds"
  end

  def self_placement           
    if @self_placement.submitted?
      flash[:notice] = "Your self placement position form has been submitted."
      redirect_to :action => "self_placement_submit", :id => @self_placement.id and return
    end
        
    if params[:self_placement_attributes] && params[:service_learning_position] && (request.put? || request.post?)                

        params[:self_placement_attributes][:organization_id] = params[:organization_id] unless params[:self_placement_attributes][:new_organization] == "1"
         
        @self_placement.update_attributes(params[:self_placement_attributes])

        # validate new organization contact fields
        if params[:self_placement_attributes][:new_organization] == "1"
          @self_placement.require_validations = true
          @self_placement.save
        end
        
        if params[:service_learning_position][:title].blank?
            return @position.errors.add :title, "cannot be blank." 
        else
            @position.title = params[:service_learning_position][:title]
        end
              
        @position.approved = false
        @position.in_progress = true
        @position.require_validations = false
        
        if @position.save && @position.update_attributes(params[:service_learning_position])
                                  
            @self_placement.update_attribute :service_learning_position_id, @position.id                        
            
            unless @position.volunteer_since
              return @position.errors.add(:volunteer_since, "Please select a date for volunteer since.")
            end            
            [:context_description, :description, :impact_description].each do |field|
                return @position.errors.add(field, "cannot be blank.") if params[:service_learning_position][field].blank?
            end                    
            if @position.times.empty? && (params[:service_learning_position][:new_times].blank? || params[:service_learning_position][:new_times] == "clear")
              return @position.errors.add_to_base "Please select a time for service learning schedule." 
            end            
            
            @self_placement.self_placement_validations = true
                                              
            if @self_placement.save
              flash.now[:notice] = "Your self placement position form sucessfully saved." if params[:commit] == "Save"     
              redirect_to :action => "self_placement_submit", :id => @self_placement.id and return if params[:commit] == "Review and Submit"
            end            
         else
            flash[:error] = "Sorry, but we could not save your information. Please try submitting again."
            redirect_to :back
         end                       
    end # request.put?              
    
    update_contact_options
           
    respond_to do |format|
       format.html
       format.js
    end
    
  end

  def self_placement_submit
    @self_placement ||= ServiceLearningSelfPlacement.find(params[:id]) if params[:id]
       if @self_placement.nil?
         flash[:error] = "Can not find your self placements."        
         redirect_to :action => :self_placement and return
       end

       redirect_to :action => :self_placement if params[:commit] == "Back to edit"

       if params[:commit] == "Submit"
         if params[:student][:electronic_signature].blank?
           flash[:error] = "Electronic signature cannot be blank."
           @student.errors.add :electronic_signature, "cannot be blank."
         else
           @student.update_attribute :service_learning_risk_signature, params[:student][:electronic_signature]
           @student.update_attribute :service_learning_risk_date, Time.now
           @student.update_attribute :service_learning_risk_date_extention, true if @service_learning_course.unit.abbreviation == 'carlson'

           @self_placement.submitted = true
           if @self_placement.save
             @self_placement.course.instructors.each do |instrutor|
               EmailContact.log(instrutor.person.id, 
               ServiceLearningMailer.deliver_templated_message(instrutor.person, 
                         EmailTemplate.find_by_name("self placement position approval request"),
                                                    instrutor.person.email,
                                                    "https://#{CONSTANTS[:base_url_host]}/faculty/service_learning/#{@quarter.abbrev}/self_placement_approval/#{@self_placement.id}",
                                                    { :student => @student,
                                                      :quarter => @quarter, 
                                                      :self_placement => @self_placement,
                                                      :faculty_link => "https://#{CONSTANTS[:base_url_host]}/faculty/service_learning/#{@quarter.abbrev}/students"})
                                                   )
           end

             flash[:notice] = "Your self placement position form sucessfully submitted. A request email has been sent to your instructor(s)."
             redirect_to :action => :self_placement and return
           end
         end
       end # end if submit
    
  end

  def general_study    
    if @self_placement.submitted?
      flash[:notice] = "Your general study form has been submitted."
      redirect_to :action => "general_study_submit", :id => @self_placement.id and return
    end
        
    if params[:self_placement_attributes] && params[:service_learning_position] && (request.put? || request.post?)
                
        params[:self_placement_attributes][:organization_id] = params[:organization_id] unless params[:self_placement_attributes][:new_organization] == "1"
        @self_placement.general_study_validations = true
        @self_placement.update_attributes(params[:self_placement_attributes])
        
        # validate new organization contact fields
        if params[:self_placement_attributes][:new_organization] == "1"
          @self_placement.require_validations = true
          @self_placement.save
        end
        
        return @position.errors.add :title, "cannot be blank." if params[:service_learning_position][:title].blank?
                
        @position.title = params[:service_learning_position][:title]
        @position.approved = false
        @position.in_progress = true
        @position.require_validations = false        

        if @position.save && @position.update_attributes(params[:service_learning_position])            
                       
            @self_placement.update_attribute :service_learning_position_id, @position.id                   
            
            @position.require_general_study_validations = true
                                              
            if @self_placement.save && @position.save
              flash[:notice] = "Your general study form sucessfully saved." if params[:commit] == "Save"     
              redirect_to :action => "general_study_submit", :id => @self_placement.id and return if params[:commit] == "Review and Submit"
            end            
         else
            flash[:error] = "Sorry, but we could not save your information. Please try submitting again."
            redirect_to :back
         end                       
    end # request.put?
    
    update_contact_options
    
    respond_to do |format|
       format.html
       format.js
    end
  end
  
  def general_study_submit    
    @self_placement ||= ServiceLearningSelfPlacement.find(params[:id]) if params[:id]

    if @self_placement.nil?
      flash[:error] = "Can not find your general study request."
      redirect_to :action => :general_study and return
    end

   redirect_to :action => :general_study if params[:commit] == "Back to edit"

       if params[:commit] == "Submit"
         if params[:service_learning_self_placement][:general_study_risk_signature].blank?
           flash[:error] = "Electronic signature cannot be blank."
           @self_placement.errors.add :general_study_risk_signature, "cannot be blank."
         else
           @self_placement.update_attribute :general_study_risk_signature, params[:service_learning_self_placement][:general_study_risk_signature]
           @self_placement.update_attribute :general_study_risk_date, Time.now

           @self_placement.submitted = true
           if @self_placement.save
             
               faculty_netid = @self_placement.faculty_email.match(/^(\w+)(@.+)?$/).try(:[], 1)
               faculty = GeneralStudyFaculty.find_by_uw_netid(faculty_netid)
               if faculty.nil?
                  # send notification to admin for adding faculty code
                  template = EmailTemplate.find_by_name("general study notification for carlson center admin staff")
                  TemplateMailer.deliver(template.create_email_to(@self_placement,                                                                  "http://#{CONSTANTS[:base_url_host]}/admin/service_learning/carlson/#{@quarter.abbrev}/courses/#{@service_learning_course.id}/instructors",
                                                                  "genst350@uw.edu")
                                        ) if template                                                               
                  #no_faculty_match_message = "Carlson Center Staff will work on the faculty you entered."
               else

                  faculty_user = User.find_by_login_and_identity_type(faculty_netid, nil)
                  if faculty_user.nil?
                    faculty_user = PubcookieUser.authenticate faculty_netid
                    faculty_user.person.update_attribute :firstname, faculty.firstname
                    faculty_user.person.update_attribute :lastname, faculty.lastname
                    faculty_user.person.update_attribute :email, @self_placement.faculty_email
                  end
                  
                  @self_placement.update_attribute :faculty_person_id, faculty_user.person

                  ServiceLearningCourseInstructor.find_or_create_by_service_learning_course_id_and_person_id(@self_placement.course.id, faculty_user.person.id)
                   
                  unless @self_placement.faculty_approved?
                      faculty_template = EmailTemplate.find_by_name("general study position faculty approval request")
                      EmailContact.log(faculty_user.person.id, 
                                       TemplateMailer.deliver(faculty_template.create_email_to(@self_placement, "https://#{CONSTANTS[:base_url_host]}/faculty/general_study/#{@quarter.abbrev}/general_study_approval/#{@self_placement.id}",
                                                                              @self_placement.faculty_email)
                                                             )
                                      )if faculty_template
                  end

                  unless @self_placement.supervisor_approved?
                    # TODO find a better way to check if new contact
                    if @self_placement.position.supervisor.nil? || !@self_placement.organization_contact_person.blank? 
                      admin_template = EmailTemplate.find_by_name("general study admin notification for new contact or organization")
                      TemplateMailer.deliver(admin_template.create_email_to(@self_placement, "https://#{CONSTANTS[:base_url_host]}/admin/service_learning/carlson/#{@quarter.abbrev}/self_placements/#{@self_placement.id}",
                                                                  "genst350@uw.edu")
                                            ) if admin_template
                    else
                      supervisor_template = EmailTemplate.find_by_name("general study position supervisor approval request")
                      EmailContact.log(@self_placement.position.supervisor.person.id, 
                                       TemplateMailer.deliver(supervisor_template.create_email_to(@self_placement, "https://#{CONSTANTS[:base_url_host]}/service_learning/#{@quarter.abbrev}/general_study/approve/#{@self_placement.id}",
                                                                      @self_placement.position.supervisor.person.email)
                                                             )
                                      ) if supervisor_template
                    end
                  end                                      
                                      
               end
               flash[:notice] = "Your general study position form sucessfully submitted. A request email has been sent to your faculty"
               redirect_to :action => :general_study and return               
            end
           end
        end # end of if submit        
  end


  protected

  def fetch_quarter
    @start_time = Time.now
    @quarter = params[:quarter_abbrev]=='current' ? Quarter.current_quarter : Quarter.find_by_abbrev(params[:quarter_abbrev])
  end
  
  def check_if_student
    unless @current_user.person.is_a? Student
      raise ServiceLearningException.new("You aren't a student.", "In order to register for a service-learning opportunity, you must
                                                                      be a registered student at the University of Washington.")
    end
  end
  
  def fetch_student
    @student = @current_user.person
  end
  
  def fetch_student_test
    unless params[:t] == "U3YxOEAGEMg4a4zD"
      render :text => "400 Bad Request", :status => 400
      return
    end
      
    enrollees = @quarter.service_learning_courses[rand(@quarter.service_learning_courses.count-1)].enrollees
    enrollees = @quarter.service_learning_courses[rand(@quarter.service_learning_courses.count-1)].enrollees if enrollees.empty?
    @student = enrollees[rand(enrollees.size-1)]
    i=0
    while i < 10 && !@student
      @student = enrollees[rand(enrollees.size-1)]
    end
    return render(:text => "couldn't find a student") unless @student
    @placements ||= @student.service_learning_placements.for(@quarter)
    return render(:text => "couldn't find a placements") unless @placements
    @quarter = Quarter.find_by_abbrev("WIN2011")
  end
  
  def fetch_enrolled_service_learning_courses
    if session[:enrolled_service_learning_course_ids]
      @enrolled_service_learning_courses = ServiceLearningCourse.find(session[:enrolled_service_learning_course_ids])
    else
      @enrolled_service_learning_courses = @student.enrolled_service_learning_courses(@quarter) #, nil) # by setting nil here, we check ALL courses except pipeline -- I changed this to not pass nil so that it will default to Carlson instead [mharris2 1/4/11]
      
      # if we don't find any Carlson classes, check Bothell too
      if @enrolled_service_learning_courses.empty?
        @enrolled_service_learning_courses = @student.enrolled_service_learning_courses(@quarter, Unit.find_by_abbreviation("bothell"))
      end
      
      session[:enrolled_service_learning_course_ids] = @enrolled_service_learning_courses.collect(&:id)
    end
  end
  
  def check_enrolled_service_learning_courses
    if @enrolled_service_learning_courses.empty?
      raise ServiceLearningException.new("You don't appear to be enrolled in any service-learning courses.", 
            "Often, this is because you recently added a class and the change has not yet appeared in our system.
             If you think this is an error, please contact the Carlson Center staff at serve@u.washington.edu immediately." )
      # if session[:non_enrolled_course].nil?
      #   redirect_to :action => "select_non_enrolled_course" and return
      # else
      #   @enrolled_service_learning_courses = [ServiceLearningCourse.find(session[:non_enrolled_course])]
      # end
    end
  end
  
  def assign_service_learning_course
    if @enrolled_service_learning_courses.size > 1
      if params[:action] == "self_placement" || params[:type] == "self_placement"
        session[:type] = "self_placement"
      end 
      redirect_to :action => "which" and return if session[:course].nil?
      @service_learning_course = @enrolled_service_learning_courses.find{|c| c.id==session[:course].to_i}
    else
      @service_learning_course = @enrolled_service_learning_courses.first
    end    
  end

  def show_minor_warning
    if @student.sdb.age < 18 && !@student.valid_service_learning_waiver_on_file?
      flash[:error] = "Since you are under 18, your parent or guardian <strong>must</strong> sign an Acknowledgement of Risk
                        form on your behalf <strong>before</strong> you can register for a service learning position. Please
                        visit the Carlson Center office in Mary Gates Hall as soon as possible."
    end
  end

  def require_waiver_if_minor
    if @student.sdb.age < 18 && !@student.valid_service_learning_waiver_on_file?
      raise ServiceLearningException.new("You must have an Acknowledgement of Risk on file.",
            "Since you are under 18, your parent or guardian <strong>must</strong> sign an Acknowledgement of Risk
            form on your behalf <strong>before</strong> you can register for a service learning position. Please
            visit the Carlson Center office in Mary Gates Hall as soon as possible.")
    end
  end

  def fetch_position
    @position = ServiceLearningPosition.find(params[:id], :include => :times)
    if @position.filled_for?(@service_learning_course)
      flash[:error] = "We're sorry, but the position you selected is no longer available. Please choose another."
      redirect_to :action => "index"
    end
  end
  
  def fetch_self_placement
    general_study_action = params[:action] == "general_study" ? true : false
      
    @self_placement = (ServiceLearningSelfPlacement.find(params[:id]) if params[:id]) || ServiceLearningSelfPlacement.find_by_person_id_and_quarter_id_and_service_learning_course_id_and_general_study(@student, @quarter, @service_learning_course, general_study_action) || ServiceLearningSelfPlacement.new                          
    
    @position = @self_placement.position || ServiceLearningPosition.new
    #@position.times.build if @position.times.empty? || !general_study_action 
    @organization = (params[:organization_id].blank?) ? Organization.find(@self_placement.try(:organization_id)) : Organization.find(params[:organization_id]) rescue nil
    @organization_options ||= Organization.all.sort_by(&:name).collect{|og| [og.name, og.id]}.insert(0, "")
  end

  def check_if_already_registered
    @placements ||= @student.service_learning_placements.for(@quarter,nil).reject{|p|p.position.general_study?}
    @current_position = @placements.first.position unless @placements.empty?
    redirect_to :action => "complete" if !@service_learning_course.open? && !@placements.empty?
  end
  
  def check_if_registration_finalized
    redirect_to :action => "index" unless @service_learning_course.finalized?
  end
  
  def check_if_registration_open
    unless @service_learning_course.open?
      raise ServiceLearningException.new("Service-learning registration is closed.")
    end
  end
  
  def check_if_registered_with_same_course
    # Stop this method if find student has a service learning placement that is already confirmed for same course
    if @student.service_learning_placements.select{|p| p.course == @service_learning_course && p.position.quarter == @quarter }.size > 0
      flash[:error] = "You already have a placement for #{@service_learning_course.title}. Please contact Carlson Center staff for self placement request."
      redirect_to :action => 'index'
    end
  end  
  
  def update_contact_options
    if params[:update_contact_options] && params[:organization_id]      
      @display_contact = true
      # Make sure the new organization checkbox is still unchecked when select existing organization name
      @new_organization = params[:self_placement_attributes][:new_organization] == "1" ? true : false
    end          
    @new_contact = @position.supervisor_person_id.nil?
  end
  

end

