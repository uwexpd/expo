class Admin::ServiceLearningController < Admin::BaseController
  before_filter :fetch_unit
  before_filter :check_unit_permission
  before_filter :service_learning_breadcrumbs
  before_filter :fetch_quarter, :except => [:hide_change_log, :mid_quarter_email_links]
  #before_filter :check_if_pipeline

  def index
    session[:breadcrumbs].add "Home"
    @show_quarter_select_dropdown = true
  end
  
  def hide_change_log
    session[:show_change_log_after] = Time.now
    render :nothing => true
  end
  
  def mid_quarter
    render :partial => "mid_quarter_email_links" and return if params[:links]
    @orgs = {}

    @organization_quarters = @quarter.organization_quarters.reject{|oq| oq.organization.active_for_quarter?(@quarter.next, @unit) || oq.organization.inactive? || oq.unit != @unit}
    @organization_quarters = @organization_quarters.sort_by(&:organization)
    @orgs[:with_all]              = @organization_quarters.select{|oq| !oq.placements.filled.empty? }
    @orgs[:self_placements_only]  = @orgs[:with_all].select{|oq| oq.self_placements_only? }
    @orgs[:with]                  = @orgs[:with_all].select{|oq| !oq.self_placements_only? }
    @orgs[:without]               = @organization_quarters.select{|oq| oq.placements.filled.empty? }
    @orgs[:inactive_until_next]   = Organization.find(:all, :conditions => { :next_active_quarter_id => @quarter.next }).reject{|o| o.active_for_quarter?(@quarter.next, @unit) || !o.inactive?}
    
    if params[:select]
      @new_quarter = @quarter.next
      params[:select].each do |obj_type,obj_hash|
        obj_hash.each do |obj_id,val|
          if obj_type == "Organization"
            o = Organization.find(obj_id)
            o.invite_for(@quarter.next, @unit)
          else
            oq = OrganizationQuarter.find(obj_id)          
            oq.allow_evals_if_active
            oq.queue_mid_quarter_emails(val, @unit)
          end
        end
      end
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
      redirect_to :back
    end
    session[:breadcrumbs].add "Mid-Quarter Check-in"
  end

  def students
     @service_learning_students ||= @quarter.service_learning_courses.for_unit(@unit).collect(&:enrollees).flatten.compact.sort
     @students = @service_learning_students.paginate(:page => params[:page], :per_page => 20)
    session[:breadcrumbs].add "Students"
  end
  
  def placements
    @carlson_placements = @quarter.service_learning_placements.select{|p| p.unit_id == @unit.id && p.filled?}
    session[:breadcrumbs].add "Placements"
  end
  
  def self_placements
    @self_placements = @quarter.service_learning_self_placements.reject{|s| s.general_study==true}
    session[:breadcrumbs].add "Self Placements"
  end
  
  def general_study
    @self_placements = @quarter.service_learning_self_placements.select{|s| s.general_study==true}
    session[:breadcrumbs].add "General Study"
  end
  
  
  # After admin approved, automatically activate organization quarter, update position quarter, create contact person, and create a placement. 
  # Then place the student into the placement
  def self_placement_approval
    @self_placement = ServiceLearningSelfPlacement.find params[:id]
    @type_of_self_placement = @self_placement.general_study? ? "General Study" : "Self Placement"
    @is_new_contact = !@self_placement.organization_contact_person.blank? && @self_placement.position.supervisor.nil?
        
    if request.put?
      if @self_placement.general_study? && !@is_new_contact
          if params[:service_learning_self_placement][:confirm_registered] == "0"
             return @self_placement.errors.add_to_base "Please check the box below to confirm you have completed registering the student."
          end
      end
      
      @self_placement.update_attribute(:admin_approved, true) unless @self_placement.general_study? && @is_new_contact
              
      if @self_placement.existing_organization?
         organization_quarter =  @self_placement.existing_organization.activate_for(@quarter, true)
         organization = organization_quarter.organization
      else
         organization = Organization.create(:name => @self_placement.organization_name,
                                            :mailing_line_1 => @self_placement.organization_mailing_line_1,
                                            :mailing_line_2 => @self_placement.organization_mailing_line_2,
                                            :mailing_city => @self_placement.organization_mailing_city,
                                            :mailing_state => @self_placement.organization_mailing_state,
                                            :mailing_zip => @self_placement.organization_mailing_zip,
                                            :website_url => @self_placement.organization_website_url,
                                            :mission_statement => @self_placement.organization_mission_statement,
                                            :approved => true
                                           )
      
         organization_quarter = organization.activate_for(@quarter, true)               
      end
      
      if @is_new_contact
         contact = organization.contacts.create
         contact_people = Person.find_all_by_email(@self_placement.organization_contact_email)
         
         if contact_people.size == 1 # if find existing person record, then create organization contact with the person record
            contact.update_attribute(:person_id, contact_people.first.id)
         elsif contact_people.size > 1
            return flash[:error] = "There are more than one person record found with the contact email. Please add the contact manually in expo."
         else
           logger.debug("Debug => create contact")
            contact.create_person(:firstname => @self_placement.organization_contact_person.split.first,
                                  :lastname => @self_placement.organization_contact_person.split.second,
                                  :email => @self_placement.organization_contact_email,
                                  :phone => @self_placement.organization_contact_phone,
                                  :title => @self_placement.organization_contact_title
                                 )           
         end
         
         organization.save;contact.save
         logger.debug("Debug => organization = #{organization.inspect}")
         logger.debug("Debug => contact = #{contact.inspect}")
         @self_placement.update_attribute(:organization_id, organization) unless @self_placement.existing_organization? # mark as existing org
         @self_placement.position.update_attribute(:supervisor_person_id, contact.person_id) if @self_placement.position.supervisor.blank?

         if @self_placement.general_study?
             supervisor_template = EmailTemplate.find_by_name("general study position supervisor approval request")
             TemplateMailer.deliver(supervisor_template.create_email_to(@self_placement, contact.login_url,
                                                             @self_placement.position.supervisor.person.email)
                                   ) if supervisor_template
         end
      end
      
      organization_quarter.statuses.find_or_create_by_organization_quarter_status_type_id(OrganizationQuarterStatusType.find_by_title("Ready").id)
            
      if @self_placement.general_study? && @is_new_contact
          flash[:notice] = "You have successfully activated the organization and created the new contact, #{@self_placement.position.supervisor.person.fullname}."
      else
          @self_placement.position.update_attributes(:organization_quarter_id => organization_quarter.id,
                                                       :unit_id =>  @unit.id,
                                                       :self_placement => !@self_placement.general_study?,
                                                       :general_study => @self_placement.general_study?,
                                                       :in_progress => false,
                                                       :approved => true,
                                                       :ideal_number_of_slots => 1,
                                                       :require_validations => false
                                                      )
          
          ServiceLearningPlacement.transaction do  
              placement = ServiceLearningPlacement.create(:service_learning_position_id => @self_placement.service_learning_position_id,
                                                          :service_learning_course_id => @self_placement.service_learning_course_id,
                                                          :created_at => Time.now, 
                                                          :unit_id => @unit.id
                                                         )        
    
              if @self_placement.person.place_into(@self_placement.position, @self_placement.course, @unit, false, !@self_placement.general_study?, @self_placement.general_study?)
                @self_placement.update_attribute(:service_learning_placement_id, placement.id) if placement
                flash[:notice] = "You successfully approved the position and place #{@self_placement.person.fullname} into a #{@type_of_self_placement.downcase}."
              else
                flash[:error] = "You have activated the organization but something went wrong when placing the student into #{@type_of_self_placement.downcase}"
                raise ActiveRecord::Rollback
              end                
          end # end transaction
            
            @self_placement.update_attributes(:registered_at => Time.now, :register_person_id => @current_user.person) if @self_placement.general_study?        
        end
                        
        redirect_to :action => @self_placement.general_study? ? "general_study" : "self_placements"
    end # end of request.put?
    
    session[:breadcrumbs].add @type_of_self_placement, @self_placement.general_study? ? service_learning_general_study_path(@unit, @quarter) : service_learning_self_placements_path(@unit, @quarter)
    session[:breadcrumbs].add "#{@type_of_self_placement} Approval"
    
  end  
  
  
  def self_placement_update
    @self_placement = ServiceLearningSelfPlacement.find params[:id]
    @type_of_self_placement = @self_placement.general_study? ? "General Study" : "Self Placement"
    @student = @self_placement.person
    @service_learning_course = @self_placement.course
    @position = @self_placement.position    
    @organization_options ||= Organization.all.sort_by(&:name).collect{|og| [og.name, og.id]}.insert(0, "")
    @organization = (params[:organization_id].blank?) ? Organization.find(@self_placement.try(:organization_id)) : Organization.find(params[:organization_id]) rescue nil
        
    if request.put? && params[:service_learning_position] && params[:self_placement_attributes]
      if params[:self_placement_attributes][:new_organization] == "1" && params[:self_placement_attributes][:organization_id].blank?
          return @self_placement.errors.add_to_base "New organization name cannot be blank."
      end
                              
      return @position.errors.add :title, "cannot be blank." if params[:service_learning_position][:title].blank?
      
      @position.require_validations = false    
      if @position.update_attributes(params[:service_learning_position])
          @self_placement.require_validations = true if params[:self_placement_attributes][:new_organization] == "1"

          if @self_placement.update_attributes(params[:self_placement_attributes])
            @self_placement.update_attribute(:organization_id, params[:organization_id]) if params[:self_placement_attributes][:new_organization] != "1"
            
            if @self_placement.general_study?
              faculty_netid = @self_placement.faculty_email.match(/^(\w+)(@.+)?$/).try(:[], 1)
              faculty = GeneralStudyFaculty.find_by_uw_netid(faculty_netid)
              unless faculty.nil?
                faculty_user = User.find_by_login_and_identity_type(faculty_netid, nil)
                if faculty_user.nil?
                  faculty_user = PubcookieUser.authenticate faculty_netid
                  faculty_user.person.update_attribute :firstname, faculty.firstname
                  faculty_user.person.update_attribute :lastname, faculty.lastname
                  faculty_user.person.update_attribute :email, @self_placement.faculty_email
                end                
                @self_placement.update_attribute :faculty_person_id, faculty_user.person
                ServiceLearningCourseInstructor.find_or_create_by_service_learning_course_id_and_person_id(@self_placement.course.id, faculty_user.person.id)
              end
            end
             
            flash[:notice] = "You have saved the #{@type_of_self_placement.downcase} position sucessfully."
            redirect_to :action => "self_placement_approval", :id => @self_placement.id and return
          end
      else
        flash[:error] = "Something went wrong when saving the self placement information"
        redirect_to :back and return
      end                  
    end
    
    # update contact person options
    if params[:update_contact_options] && params[:organization_id]      
      @display_contact = true
      @new_organization = params[:self_placement_attributes][:new_organization] == "1" ? true : false
    end
    @new_contact = @position.supervisor_person_id.nil? if @self_placement.general_study?
        
    session[:breadcrumbs].add "#{@type_of_self_placement} Approval", service_learning_self_placement_approval_path(@unit, @quarter, params[:id])
    session[:breadcrumbs].add "#{@type_of_self_placement} Edit"
    
    respond_to do |format|
       format.html
       format.js
    end
    
  end
  
  protected

  def fetch_quarter
    @quarter = (params[:quarter_abbrev] ? Quarter.find_by_abbrev(params[:quarter_abbrev]) : Quarter.current_quarter) || Quarter.current_quarter
    session[:breadcrumbs].add "#{@quarter.title}", service_learning_home_path(@unit, @quarter), :class => 'quarter_select'
  end

  def service_learning_breadcrumbs
    session[:breadcrumbs].add @unit.name, service_learning_home_path(@unit, nil)
  end
  
  def fetch_unit
    @unit = params[:unit] ? Unit.find_by_abbreviation(params[:unit]) : Unit.find_by_abbreviation("carlson")
    
    # see if the units is nil, if so see if it was a quarter abbrev, if so redirect to unit of carlson
    if @unit.nil? && !params[:unit].match(/\D\D\D\d\d\d\d/).nil?
      flash[:error] = "No unit abbreviation was included in the URL. You have been redirected to Carlson's Service Learning module."
      return redirect_to service_learning_home_path("carlson", params[:unit])
    end
    
    @unit_abbrev = @unit.abbreviation
    
    @use_pipeline_links = true if @unit_abbrev == "pipeline"
  end

  def check_unit_permission
    require_user_unit @unit
  end
  
=begin
  def check_if_pipeline
    if params[:from_pipeline]
      ### very basic redirecting of the service learning links 
      service_learning_uri = request.request_uri
      pipeline_uri = service_learning_uri.gsub("service_learning","pipeline")
      redirect_to pipeline_uri
    end
  end
=end
end
