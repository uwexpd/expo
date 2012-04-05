class Admin::Pipeline::OrganizationsController < Admin::PipelineController
  before_filter :add_to_breadcrumbs
  
  # GET /organizations
  # GET /organizations.xml
  def index
    
    # had to get rid of find_and_sort and params[:order] in the order part to make conditions work
    @organization_quarters = @quarter.organization_quarters.find(:all, :conditions => {:unit_id => @unit.id}, 
                                                                 :order => ('organizations.name'), 
                                                                 :include => [:organization])

    # @organization_quarters.sort!{ |x,y| x.status.sequence <=> y.status.sequence rescue 0 }
    # @status_types = OrganizationQuarterStatusType.find :all, :order => 'sequence'
    
    @show_quarter_select_dropdown = true
    
    respond_to do |format|
      format.html { render :template => "admin/service_learning/organizations/index" }
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
      redirect_to admin_pipeline_organization_path(new_quarter, @organization) and return
    end
    @organization = @organization_quarter.organization
    session[:breadcrumbs].add @organization.name
    
    @organization_quarter.reload
    
    respond_to do |format|
      format.html { render :template => "admin/service_learning/organizations/show" }
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
      format.html { render :template => "admin/service_learning/organizations/new" }
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
        format.html { redirect_to(admin_pipeline_organization_path(@quarter, @organization)) }
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
        format.html { redirect_to(admin_pipeline_organization_path(@quarter, @organization)) }
        format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "show" }
        format.js   { render(:update) {|page| page.replace_html "course_match_error", 
                          render(:inline => "<%= error_messages_for(:organization_quarter) %>") } }
        format.xml  { render :xml => @organization_quarter.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def new_position
    @organization_quarter = OrganizationQuarter.find(:first, :conditions => {organization_id => params[:id], quarter_id => @quarter.id, :unit_id => @unit.id})
    @service_learning_position = @organization_quarter.positions.create
  end
  
  def activate
    @organization = Organization.find params[:activate][:organization_id]
    @organization.update_attribute(:does_pipeline, true)
    @organization.activate_for(@quarter, true, @unit)
    redirect_to(admin_pipeline_organization_path(@quarter, @organization))
  end
  
  # this should be probably be changed to specify that it is pipeline that is allowing the position edits
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
  
  # remove organization from that quarter
  def remove_organization_quarter
    @organization_quarter = OrganizationQuarter.find params[:organization_quarter_id]
    @organization_quarter.destroy
    
    respond_to do |format|
      format.js
    end
  end
  
  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "#{@quarter.title}", admin_pipeline_positions_path(@quarter), :class => 'quarter_select'
    session[:breadcrumbs].add "Organizations", "."
  end
  
end