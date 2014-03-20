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
    @self_placements = @quarter.service_learning_self_placements
    session[:breadcrumbs].add "Self Placements"
  end

  # After admin approved, automatically activate organization quarter, update position quarter, create contact person, and create a placement. 
  # Then place the student into the placement
  def self_placement_approval
    @self_placement = ServiceLearningSelfPlacement.find params[:id]
    
    session[:breadcrumbs].add "Self Placements", service_learning_self_placements_path(@unit, @quarter)
    session[:breadcrumbs].add "Self Placement Approval"
    
    if request.put?
        if @self_placement.update_attribute(:admin_approved, true)
            if @self_placement.existing_organization?
               organization_quarter =  @self_placement.existing_organization.activate_for(@quarter, true)             
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

               contact = organization.contacts.create
               contact.create_person(:firstname => @self_placement.organization_contact_person.split.first,
                                                   :lastname => @self_placement.organization_contact_person.split.second,
                                                   :email => @self_placement.organization_contact_email,
                                                   :phone => @self_placement.organization_contact_phone,
                                                   :title => @self_placement.organization_contact_title
                                                  )
               organization.save;contact.save
               @self_placement.update_attribute(:organization_id, organization) # mark as existing org
               @self_placement.position.update_attribute(:supervisor_person_id, contact.id)
            end

          organization_quarter.statuses.create :organization_quarter_status_type_id => OrganizationQuarterStatusType.find_by_title("Ready").id
          
          @self_placement.position.update_attributes(:organization_quarter_id => organization_quarter.id,
                                                     :unit_id =>  @unit.id,
                                                     :self_placement => true,
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

              if @self_placement.person.place_into(@self_placement.position, @self_placement.course)
                @self_placement.update_attribute(:service_learning_placement_id, placement.id) if placement
                flash[:notice] = "You successfully approved the position and place #{@self_placement.person.fullname} into a self placement."
              else
                flash[:error] = "You have activated the organization but something went wrong when placing the student into self placement"
                raise ActiveRecord::Rollback
              end        
          end
              
        end # update admin_approved
        redirect_to :action => 'self_placements'      
    end # end of request.put?
  end  
  
  
  def self_placement_update
    @self_placement = ServiceLearningSelfPlacement.find params[:id]
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
            flash[:notice] = "You have saved the self placement position sucessfully."
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
        
    session[:breadcrumbs].add "Self Placement Approval", service_learning_self_placement_approval_path(@unit, @quarter, params[:id])
    session[:breadcrumbs].add "Self Placement Edit"
    
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
