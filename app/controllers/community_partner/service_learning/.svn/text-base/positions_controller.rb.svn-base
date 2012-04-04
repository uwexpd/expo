class CommunityPartner::ServiceLearning::PositionsController < CommunityPartner::ServiceLearningController
  before_filter :check_if_position_edits_are_allowed, :except => [:index, :show]
  before_filter :add_positions_breadcrumbs
#  before_filter :check_for_previous_quarters, :only => [:copy_from_previous]

  uses_tiny_mce

  def index
    # @positions = @organization_quarter.positions.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @position = @organization.service_learning_positions.find(params[:id])
    
    session[:breadcrumbs].add @position.title(false, false, false)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @position = @organization.service_learning_positions.new
    
    session[:breadcrumbs].add "Create New"
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @position = @organization.service_learning_positions.find(params[:id], :include => :times)
    
    session[:breadcrumbs].add @position.title(false, false, false), community_partner_service_learning_position_path(@quarter, @position)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @position = @organization.service_learning_positions.new(params[:service_learning_position])
    @position.organization_quarter_id = @organization_quarters.first.id if @organization_quarters.size == 1
    @position.unit_id = @position.organization_quarter.try(:unit_id)
    @position.approved = false
    @position.in_progress = true

    respond_to do |format|
      if @position.save
        default_note = 'Your position was successfully created. Now you need to complete the remaining details.'
        flash[:notice] = HelpText.caption(:after_create_note, ServiceLearningPosition) || default_note
        format.html { redirect_to(edit_community_partner_service_learning_position_path(@quarter, @position, :anchor => "description")) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @position = @organization.service_learning_positions.find(params[:id])
    @position.in_progress = request.xhr? ? true : false
    @position.require_ideal_number_of_slots = false if request.xhr?

    respond_to do |format|
       # && @position.update_attribute(:number_of_slots, @position.new_number_of_slots)
      if @position.update_attributes(params[:service_learning_position]) && @position.update_attribute(:approved, false)
        @position.update_attribute(:unit_id, @position.organization_quarter.try(:unit_id))
        pending_message = 'Position was successfully updated and will be sent to service-learning staff for approval.'
        flash[:notice] = pending_message unless @position.in_progress?
        format.html { redirect_to(community_partner_service_learning_position_path(@quarter, @position)) }
        format.js
      else
        @current_tab_pane = :requirements if @position.errors.on(:ideal_number_of_slots)
        format.html { render :action => "edit" }
        format.js   { @error = true }
      end
    end
  end

  def destroy
    @position = @organization.service_learning_positions.find(params[:id])
    @position.destroy

    respond_to do |format|
      format.html { redirect_to(community_partner_service_learning_positions_url) }
    end
  end
  
  def copy_from_previous
    session[:breadcrumbs].add "Copy"
    
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
        redirect_to community_partner_service_learning_positions_url
      end
    end
    
  end
  
  protected
  
  def check_if_position_edits_are_allowed
    unless @organization_quarters.collect(&:allow_position_edits?).include?(true)
    # unless @organization_quarter.allow_position_edits?
      flash[:error] = "You are not allowed to create, edit, or delete positions at this time."
      redirect_to :action => "index"
    end
  end

  def add_positions_breadcrumbs
    session[:breadcrumbs].add "Positions", community_partner_service_learning_positions_path(@quarter)
  end

  def check_for_previous_quarters
    if @organization.organization_quarters.size <= 1
      new_url = new_community_partner_service_learning_position_url
      flash[:error] = "Sorry, but your organization has no previous quarters from which to copy positions.
                        <br>Would you like to <a href='#{new_url}'>create a brand new position</a> instead?"
      redirect_to :action => "index"
    end
  end
end
