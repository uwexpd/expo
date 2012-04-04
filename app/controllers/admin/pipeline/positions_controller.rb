class Admin::Pipeline::PositionsController < Admin::PipelineController
  before_filter :fetch_quarter
  before_filter :fetch_unit
  before_filter :pipeline_positions_breadcrumbs
  
  def index
    @pipeline_positions = @quarter.pipeline_positions
    
    @pipeline_positions.sort!{|x,y| x.organization.name <=> y.organization.name}
    @show_quarter_select_dropdown = true
    
    if params[:quarter_from]
      @migrate_to_current_quarter = true
      @quarter_to_migrate_to = Quarter.find_by_abbrev(params[:quarter_from])
      
      already_copied = @quarter_to_migrate_to.pipeline_positions.collect{|p| p.previous_service_learning_position_id}.compact
      
      @pipeline_positions = @pipeline_positions.reject{|p| already_copied.include?(p.id)}
      
    end
    
    
    respond_to do |format|
      format.html { render :template => "admin/service_learning/positions/index" }
      format.xml  { render :xml => @pipeline_positions }
    end
  end
  
  def migrate_to_current_quarter
    @quarter_to_migrate_to = Quarter.find_by_abbrev(params[:quarter_from])
    
    @pipeline_positions = ServiceLearningPosition.find(params[:position_ids])
    
    @organization_quarter = nil
    @pipeline_positions.each do |pipeline_position|
      @organization_quarter = OrganizationQuarter.find(:first, 
                                                       :conditions => {:organization_id => pipeline_position.organization.id,
                                                                       :quarter_id => @quarter_to_migrate_to.id,
                                                                       :unit_id => @unit.id})
      if @organization_quarter.nil?
        @organization_quarter = OrganizationQuarter.create( :organization_id => pipeline_position.organization.id,
                                                            :quarter_id => @quarter_to_migrate_to.id,
                                                            :unit => @unit )
      end
      
      new_position = pipeline_position.clone(['details','times','supervisor','location','pipeline_position'])
      new_position.update_attribute(:organization_quarter_id, @organization_quarter.id)
      
      new_position.save
    end
    
    redirect_to :action => "index", :quarter_abbrev => params[:quarter_from]
  end
  
  protected
  
  def pipeline_positions_breadcrumbs
    session[:breadcrumbs].add "#{@quarter.title}", admin_pipeline_positions_path(@quarter), :class => 'quarter_select'
    session[:breadcrumbs].add "Positions", admin_pipeline_positions_path
  end
  
end