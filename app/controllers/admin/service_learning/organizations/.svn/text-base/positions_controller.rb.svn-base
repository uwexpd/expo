class Admin::ServiceLearning::Organizations::PositionsController < Admin::ServiceLearningController
  before_filter :fetch_organization
  before_filter :service_learning_organization_positions_breadcrumbs
  skip_before_filter :check_unit_permission, :only => :show
  before_filter :check_service_learning_position_permission, :only => :show

  uses_tiny_mce
  # uses_google_maps
  
  # GET /service_learning_positions
  # GET /service_learning_positions.xml
  def index
    @service_learning_positions = @organization_quarter.positions
    @service_learning_positions.sort!{|x,y| x.organization.name <=> y.organization.name}
    @show_quarter_select_dropdown = true
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_learning_positions }
    end
  end

  # GET /service_learning_positions/1
  # GET /service_learning_positions/1.xml
  def show
    @service_learning_position = @organization_quarter.positions.find(params[:id])
    session[:breadcrumbs].add @service_learning_position.title(true, true, false)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service_learning_position }
    end
  end

  # GET /service_learning_positions/new
  # GET /service_learning_positions/new.xml
  def new
    @service_learning_position = ServiceLearningPosition.new
    @service_learning_position.organization_quarter_id = @organization_quarter.id
    @service_learning_position.times.build
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_learning_position }
    end
  end

  # GET /service_learning_positions/1/edit
  def edit
    @service_learning_position = ServiceLearningPosition.find(params[:id])
    session[:breadcrumbs].add "#{@service_learning_position.title(true, true, false)}", :action => 'show'
    session[:breadcrumbs].add "Edit"
  end

  # POST /service_learning_positions
  # POST /service_learning_positions.xml
  def create
    @service_learning_position = @organization_quarter.positions.create(params[:service_learning_position])
    @service_learning_position.unit = @unit
    @service_learning_position.approved = false
    @service_learning_position.in_progress = true
    
    respond_to do |format|
      if @service_learning_position.save
        flash[:notice] = 'ServiceLearningPosition was successfully created.'
        format.html { redirect_to edit_service_learning_organization_position_path(@unit, 
                                  @quarter, @organization, @service_learning_position, :anchor => 'description') }
        format.xml  { render :xml => @service_learning_position, :status => :created, :location => @service_learning_position }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_learning_position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_learning_positions/1
  # PUT /service_learning_positions/1.xml
  def update
    @service_learning_position = ServiceLearningPosition.find(params[:id])
    @service_learning_position.approved = params[:mark_pending] ? false : true
    @service_learning_position.in_progress = false
    if request.xhr?
      @service_learning_position.in_progress = true
      @service_learning_position.approved = false
    end

    # # This next line allows us to remove the last time from a position. We need it because if ALL times have
    # # been removed, then we don't get an +existing_time_attributes+ param hash, and we don't know to delete the last one.
    # # But, this also means that _without_ passing this attribute, we delete ALL times (which is bad). So, in order
    # # to run this line you must pass a +remove_times_if_missing+ param.
    # params[:service_learning_position][:existing_time_attributes] ||= {} if params[:remove_times_if_missing]

    respond_to do |format|
      # if !params[:service_learning_position][:existing_time_attributes]
      #   @service_learning_position.times.reject(&:new_record?).each{|t| @service_learning_position.times.delete(t)}
      # end
      if @service_learning_position.update_attributes(params[:service_learning_position])
        @service_learning_position.update_attribute(:unit_id, @service_learning_position.organization_quarter.try(:unit_id))        
        flash[:notice] = "Position \"#{@service_learning_position.title rescue nil}\" sucessfully updated."
        format.html { redirect_to service_learning_organization_position_path(@unit, @quarter, @organization, @service_learning_position) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_learning_position.errors, :status => :unprocessable_entity }
        format.js   { @error = true }
      end
    end
  end

  # DELETE /service_learning_positions/1
  # DELETE /service_learning_positions/1.xml
  def destroy
    @service_learning_position = ServiceLearningPosition.find(params[:id])
    @service_learning_position.destroy

    respond_to do |format|
      format.html { redirect_to(service_learning_organization_positions_url(@unit, @quarter, @organization)) }
      format.xml  { head :ok }
    end
  end

  def copy_from_previous
    session[:breadcrumbs].add "Copy"

    @organization_quarters = [@organization_quarter] # The view file expects this to be an array because we are using the
                                                     # view file from the community partner side.
    @previous_quarter_options = []
    for quarter in @organization.active_quarters.uniq.sort.reverse
      position_count = @organization.service_learning_positions.count(
                          :conditions => { :organization_quarters => { :quarter_id => quarter }})
      next if position_count.zero?
      key = "#{quarter.title} (#{@template.pluralize(position_count, "position")})"
      value = quarter.id
      @previous_quarter_options << [key, value]
    end
    
    if params[:previous_quarter_id]
      @previous_quarter = Quarter.find params[:previous_quarter_id]
      @positions = @organization.service_learning_positions.find(:all, 
                        :conditions => { :organization_quarters => { :quarter_id => @previous_quarter }})
    end
    
    if params[:position] && params[:copy]
      ServiceLearningPosition.transaction do
        params[:position].each do |position_id|
          new_position = @organization.service_learning_positions.find(position_id).clone(params[:copy])          
          if new_position
            new_position.update_attribute(:organization_quarter_id, params[:new_organization_quarter_id])             
            new_unit_id = OrganizationQuarter.find(params[:new_organization_quarter_id]).unit_id
            new_position.update_attribute(:unit_id, new_unit_id)
          end                    
        end
        flash[:notice] = "Successfully created new service learning positions."
        redirect_to service_learning_organization_url(@unit, @quarter, @organization, :anchor => 'positions') and return
      end
    end
  
    render :template => 'community_partner/service_learning/positions/copy_from_previous'
  end

  
  private
  
  def service_learning_organization_positions_breadcrumbs
    session[:breadcrumbs].add "Organizations", service_learning_organizations_path(@unit, @quarter)
    session[:breadcrumbs].add @organization.name, service_learning_organization_path(@unit, @quarter, @organization)
    session[:breadcrumbs].add "Positions", service_learning_organization_positions_path
  end
  
  def fetch_organization
    @organization_quarter = @quarter.organization_quarters.find_by_organization_id_and_unit_id(params[:organization_id], @unit.id)
    unless @organization_quarter
      flash[:error] = "You tried to access that organization for a quarter that it hasn't been activated
                      for. Try again with a different quarter."
      redirect_to :back 
    end
    @organization = @organization_quarter.organization
    @organization_quarters = @organization.organization_quarters.for_quarter(@quarter)
  end
  
  # Carlson and Piple can see the positions for each other
  def check_service_learning_position_permission 
    unless @current_user.in_unit?(Unit.find_by_abbreviation("carlson")) || @current_user.in_unit?(Unit.find_by_abbreviation("pipeline")) || @current_user.in_unit?(Unit.find_by_abbreviation("bothell"))
      require_user_unit @unit
    end
  end
  
end
