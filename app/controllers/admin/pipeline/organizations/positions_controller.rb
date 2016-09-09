class Admin::Pipeline::Organizations::PositionsController < Admin::PipelineController
  before_filter :fetch_organization
  before_filter :pipeline_organization_positions_breadcrumbs
  
  skip_before_filter :fetch_organization, :pipeline_organization_positions_breadcrumbs, :only => [:remote_add_subject]
  
  uses_tiny_mce
  # uses_google_maps

  def copy_from_previous
    session[:breadcrumbs].add "Copy Previous Position(s)"
  
    if params[:previous_quarter_id]
      @previous_organization_quarter = @organization.organization_quarters.find(params[:previous_quarter_id])
    end
  
    if params[:position] && params[:copy]
      params[:position].each do |position_id|
        new_position = @organization.pipeline_positions.find(position_id).clone(params[:copy])
        new_position.update_attribute(:organization_quarter_id, @organization_quarter.id)
      end
      flash[:notice] = "Successfully created new service learning positions."
      redirect_to admin_pipeline_organization_url(@quarter, @organization, :anchor => 'positions') and return
    end
  
    render :template => 'community_partner/service_learning/positions/copy_from_previous'
  end

  def remote_add_subject
    
    @subject = nil
    unless params[:subject][:name].empty?
      @subject = PipelinePositionsSubject.create(params[:subject])
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def remote_add_language_spoken
    
    @language_spoken = nil
    unless params[:language_spoken][:name].empty?
      @language_spoken = PipelinePositionsLanguageSpoken.create(params[:language_spoken])
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def update_course_slots
    unless params[:update_course_slots][:course_id].empty?
      @service_learning_position = ServiceLearningPosition.find params[:id]
      course_id = nil
      course_id = params[:update_course_slots][:course_id] unless params[:update_course_slots][:course_id] == "v"
      placements = course_id.nil? ? @service_learning_position.placements.unallocated : @service_learning_position.placements.for(ServiceLearningCourse.find(course_id))
    
      number_of_slots = Integer(params[:update_course_slots][:number_of_slots]) rescue 0
      number_of_slots = number_of_slots - placements.size
    
      unless number_of_slots <= 0
        (0...number_of_slots).each do
          ServiceLearningPlacement.create(:service_learning_position_id => params[:id],
                                          :service_learning_course_id => course_id,
                                          :unit_id => @unit.id)
        end
      end
      if number_of_slots < 0
        removable_placements = placements.collect{|p| p if p.person_id == nil}.compact
        number_of_slots = (removable_placements.size >= number_of_slots.abs) ? number_of_slots.abs : removable_placements.size
        (0...number_of_slots).each do |n|
          removable_placements[n].destroy
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  private
  
  def pipeline_organization_positions_breadcrumbs
    session[:breadcrumbs].add "#{@quarter.title}", admin_pipeline_positions_path(@quarter), :class => 'quarter_select'
    session[:breadcrumbs].add "Organizations", admin_pipeline_organizations_path(@quarter)
    session[:breadcrumbs].add @organization.name, admin_pipeline_organization_path(@quarter, @organization)
    session[:breadcrumbs].add "Positions", admin_pipeline_organization_positions_path
  end
  
  def fetch_organization
    @organization_quarter = OrganizationQuarter.find(:first, :conditions => {:organization_id => params[:organization_id], :quarter_id => @quarter.id, :unit_id => @unit.id})
    @organization = @organization_quarter.organization
  end
end
