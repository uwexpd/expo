class Admin::ServiceLearning::OrganizationsController < Admin::ServiceLearningController
  before_filter :add_to_breadcrumbs
  before_filter :fetch_organization_quarters, :only => [:index, :partner_access]
  
  # GET /organizations
  # GET /organizations.xml
  def index
    @show_quarter_select_dropdown = true
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organization_quarters }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    @organization_quarter = @quarter.organization_quarters.find_by_organization_id_and_unit_id(params[:id], @unit.id)
    if @organization_quarter.nil?
      @organization = Organization.find params[:id]
      new_quarter = @organization.last_organization_quarter(@unit).quarter rescue nil
      raise ActiveRecord::RecordNotFound and return if new_quarter.nil?
      flash[:error] = "Since this organization is not activated for #{@quarter.title}, we've redirected you to #{new_quarter.title} instead."
      redirect_to service_learning_organization_path(@unit, new_quarter, @organization) and return
    end
    @organization = @organization_quarter.organization
    session[:breadcrumbs].add @organization.name
    
    @organization_quarter.reload
    
    @other_organization_quarters = @organization.organization_quarters.find(:all,
                                                      :conditions=>["unit_id != ? AND quarter_id = ?",
                                                                        @organization_quarter.unit_id,
                                                                        @quarter.id])
        
    respond_to do |format|
      format.html # show.html.erb
      format.js   { render :partial => "admin/service_learning/organizations/tabs/#{params[:tab]}" and return if params['tab'] }
      format.xml  { render :xml => @organization_quarter }
    end
  end

  # GET /organizations/new
  # GET /organizations/new.xml
  def new
    @organization = Organization.new
    session[:breadcrumbs].add "New"
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # POST /organizations
  # POST /organizations.xml
  def create
    @organization = Organization.new(params[:organization])

    respond_to do |format|
      if @organization.save
        OrganizationQuarter.create :organization_id => @organization.id, :quarter_id => @quarter.id, :unit_id => @unit.id
        flash[:notice] = 'Organization was successfully created.'
        format.html { redirect_to(service_learning_organization_path(@unit, @quarter, @organization)) }
        format.xml  { render :xml => @organization, :status => :created, :location => @organization }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @organization_quarter = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(params[:id], @quarter.id, @unit.id)
    @organization = @organization_quarter.organization

    respond_to do |format|
      if @organization_quarter.update_attributes(params[:organization_quarter])
        flash[:notice] = 'Organization was successfully updated.'
        format.html { redirect_to(service_learning_organization_path(@unit, @quarter, @organization)) }
        format.js
        format.xml  { head :ok }
      else
        flash[:error] = 'Organization was not updated. '+@organization_quarter.errors.full_messages.join(". ")
        format.html { redirect_to(service_learning_organization_path(@unit, @quarter, @organization)) }
        format.js   { render(:update) {|page| page.replace_html "course_match_error", 
                          render(:inline => "<%= error_messages_for(:organization_quarter) %>") } }
        format.xml  { render :xml => @organization_quarter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    @organization = Organization.find params[:activate][:organization_id]
    @organization.update_attribute(:does_service_learning, true)
    @organization.activate_for(@quarter, true, @unit)
    redirect_to(service_learning_organization_path(@unit, @quarter, @organization))
  end

  def deactivate
    @organization = Organization.find params[:deactivate][:organization_id]
    oq = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(@organization.id, @quarter.id, @unit.id)
    if oq.destroy
      flash[:notice] = "#{@organization.name} has been de-activated for #{@quarter.title}"
    else
      flash[:error] = "Could not de-activate that organization."
    end
    redirect_to(service_learning_organizations_path(@unit, @quarter))
  end

  def add_note
    @organization = Organization.find(params[:id])
    @note = @organization.notes.create(params[:note])
    
    respond_to do |format|
      format.html { redirect_to service_learning_organization_path(@unit, @quarter, @organization) }
      format.js
    end
  end
  
  def new_position
    @organization_quarter = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(params[:id], @quarter.id, @unit.id)
    @service_learning_position = @organization_quarter.positions.create
  end

  def partner_access
    #@organization_quarters = @quarter.organization_quarters.find_all_by_unit_id(@unit.id).sort_by(&:name)
    #@status_types = OrganizationQuarterStatusType.find :all, :order => 'sequence'    
    @show_quarter_select_dropdown = true
    
    session[:breadcrumbs].add "Partner Access"
  end
  
  def allow_position_edits
    @organization_quarter = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(params[:id], @quarter.id, @unit.id)
    @organization_quarter.toggle_allow_position_edits
    respond_to do |format|
      format.html { redirect_to :action => "partner_access" }
      format.js
    end
  end
  
  def allow_evals
    @organization_quarter = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(params[:id], @quarter.id, @unit.id)
    @organization_quarter.toggle_allow_evals
    respond_to do |format|
      format.html { redirect_to :action => "partner_access" }
      format.js
    end
  end
  
  def delete_course_match
    @organization_quarter = @quarter.organization_quarters.find_by_organization_id_and_unit_id(params[:id], @unit.id)
    @organization = @organization_quarter.organization

    if params[:course_id]
      @organization_quarter.delete_potential_course_match(params[:course_id])
      flash[:notice] = "Removed potential course match."
    end

    respond_to do |format|
      format.html { redirect_to :action => "show" }
      format.js   { }
    end
  end
  
  def toggle_position_edits
    if params[:select].blank?
      flash[:error] = "Please select at least one organization first."
      redirect_to :action => "partner_access" and return
    end
    params[:select].each do |obj_type,objects|
      objects.each do |obj_id,value|
        obj = eval("#{obj_type}.find(#{obj_id})")
        if obj.is_a? OrganizationQuarter
          new_value = params[:value] || !obj.allow_position_edits?
          obj.update_attribute :allow_position_edits, new_value
        end
      end
    end
    redirect_to :action => "partner_access"
  end
  
  def toggle_evals
    if params[:select].blank?
      flash[:error] = "Please select at least one organization first."
      redirect_to :action => "partner_access" and return
    end
    params[:select].each do |obj_type,objects|
      objects.each do |obj_id,value|
        obj = eval("#{obj_type}.find(#{obj_id})")
        if obj.is_a? OrganizationQuarter
          new_value = params[:value] || !obj.allow_evals?
          obj.update_attribute :allow_evals, new_value
        end
      end
    end
    redirect_to :action => "partner_access"
  end
  
  def students
    @organization_quarter = @quarter.organization_quarters.find_by_organization_id_and_unit_id(params[:id], @unit.id)
    @students = @organization_quarter.students
    
    respond_to do |format|
      format.xls { render :action => 'students', :layout => 'basic' }
    end
  end

  # remove organization from that quarter
  def remove_organization_quarter
    @organization_quarter = @quarter.organization_quarters.find params[:id]
    @organization_quarter.destroy
    
    respond_to do |format|
      format.js
    end
  end

  # If pipeline students confirm their positions, then
  #     1. activate the organization if it is inactive in carlson end
  #     2  Search if there is a current carlson position match pipeline position in the same organization by using position title, organization_quarter, and unit_id
  #        * if so, don't clone the position and just use current one.
  #        * If not, add a carlson service-learning position in carlson end
  #     3. place the student into the position in carlson end (update the new position into pipeline-project placement, which means removing pipeline-project placement)
  def match_pipeline_placement
    @organization = Organization.find(params[:organization]) if params[:organization]
    if params[:select]
      updated_placements = []
      no_pipeline_courses_students = []
      no_pipeline_placements_students = []
      
      for object_type, ids in params[:select]
        if object_type == 'ServiceLearningPlacement'
          for id, val in ids
            placement = ServiceLearningPlacement.find(id)            
            student = placement.person            
            course_param = placement.course.courses.first.abbrev
            
            # Find pipeline course and placement
            pipeline_course = ServiceLearningCourseCourse.find_by_abbrev_and_quarter(course_param, @quarter, Unit.find_by_abbreviation("pipeline")).service_learning_course
            
            if pipeline_course
              pipeline_placement = ServiceLearningPlacement.find_by_person_id_and_service_learning_course_id(student.id, pipeline_course.id)
            else
              no_pipeline_courses_students << student.lastname              
            end            
                        
            if pipeline_placement
              # Check if organization quarter exits, if not, then create.
              organization_quarter = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(pipeline_placement.organization.id, @quarter, @unit)
              if organization_quarter.nil?
                 organization_quarter = OrganizationQuarter.create(:organization_id => pipeline_placement.organization.id,
                                                                   :quarter_id => @quarter.id,
                                                                   :unit_id => @unit.id)
              end
              
              # Check if Carlson already has the position. If not, then clone the position.
              postion = ServiceLearningPosition.find_by_title_and_organization_quarter_id_and_unit_id(pipeline_placement.position.title, organization_quarter.id, @unit)              
              if postion
                @new_position = postion
              else
                @new_position = pipeline_placement.position.clone(['details','times','supervisor','location','approved','ideal_number_of_slots'])
                @new_position.update_attribute(:organization_quarter_id, organization_quarter.id)
                @new_position.update_attribute(:unit_id, @unit)
                @new_position.save
              end
              
              if ServiceLearningPlacement.find_by_person_id_and_service_learning_position_id_and_service_learning_course_id_and_unit_id(student.id, @new_position.id, placement.course.id, @unit).nil?
                placement.update_attribute(:service_learning_position_id, @new_position.id)
                placement.save
              end
              updated_placements << placement              
              
            else
              no_pipeline_placements_students << student.lastname
            end 
            
          end # end for loop
          
        end 
      end
      flash[:notice] = "Matched #{updated_placements.size} pipeline placement(s) to carlson end." unless updated_placements.blank?
      flash[:error] = "Cannot find student's enrolled course(s) in pipeline placement: #{no_pipeline_courses_students.join(', ')}" unless no_pipeline_courses_students.blank?
      flash[:error] = "Cannot find student's placement(s) in pipeline end: #{no_pipeline_placements_students.join(', ')}" unless no_pipeline_placements_students.blank?
      
    else
      flash[:error] = "Please select at least one student first."
    end    
    redirect_to(service_learning_organization_path(@unit, @quarter, @organization, :anchor => "students"))
  end  
  

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Organizations", "."
  end
  
  def fetch_organization_quarters
    #@organization_quarters = @quarter.organization_quarters.find_and_sort(:all, :order => (params[:order] || 'name')).reject{ |oq| oq.organization.archive? || oq.inactive_status? }
    @organization_quarters = OrganizationQuarter.find(:all, 
      :select => "organization_quarters.*, (
                    SELECT GROUP_CONCAT(u.abbreviation) AS abbrevs 
                    FROM organization_quarters AS oqo, units AS u 
                    WHERE u.id = oqo.unit_id 
                    AND oqo.organization_id = organization_quarters.organization_id 
                    AND oqo.quarter_id = organization_quarters.quarter_id 
                    AND oqo.unit_id != organization_quarters.unit_id) AS units,
                  	(
                  	SELECT oqs.organization_quarter_status_type_id
                  	FROM organization_quarters AS oqo, organization_quarter_statuses AS oqs
                  	WHERE oqs.organization_quarter_id = oqo.id
                  	AND oqo.id = organization_quarters.id
                  	ORDER BY oqs.updated_at DESC
                  	LIMIT 1) AS current_status_type_id", 
    	:conditions => {:unit_id => @unit.id, 
    	                :quarter_id => @quarter.id}, 
    	:joins => [:organization], 
    	:order => ('organizations.name')).reject{ |oq| oq.organization.archive? }
    	
    #.reject{ |oq| oq.organization.archive? || oq.inactive_status? }
    #@organizations = Hash[*Organization.find(@organization_quarters.collect(&:organization_id)).collect { |o| [o.id, o.name] }.flatten]
    
    @organizations = {}
    @inactive_organizations = {}
    @inactive_organization_names = {}
    organization_quarters_ids = @organization_quarters.collect(&:organization_id)
    Organization.all.each do |o|
      next if o.archive?
      if organization_quarters_ids.include?(o.id)
        @organizations[o.id] = {:name => o.name, :target_school => o.target_school}
      else
        @inactive_organizations[o.id] = {:name => o.name, :target_school => o.target_school}
        @inactive_organization_names[o.id] = o.name
      end
    end
    
    @used_status_types = (OrganizationQuarterStatusType.find(@organization_quarters.collect(&:current_status_type_id).uniq) rescue []) << nil
    @status_types = Hash[*OrganizationQuarterStatusType.all.collect { |o| [o.id, o] }.flatten]
    # @organization_quarters.sort!{ |x,y| x.status.sequence <=> y.status.sequence rescue 0 }
    # @status_types = OrganizationQuarterStatusType.find :all, :order => 'sequence'
  end

end
