class Admin::ServiceLearning::PositionsController < Admin::ServiceLearningController
  before_filter :service_learning_positions_breadcrumbs
  
  # GET /service_learning_positions
  # GET /service_learning_positions.xml
  def index
    #@service_learning_positions = @quarter.service_learning_positions.for_unit(@unit)
    #@service_learning_positions.sort!{|x,y| x.organization.name <=> y.organization.name}
    
    @service_learning_positions = ServiceLearningPosition.find(:all, 
        :include => [{:organization_quarter => :organization}],
        :conditions => {:organization_quarters => {:quarter_id => @quarter.id, :unit_id => @unit.id}},
        :order => "organizations.name"
        )
      
    @show_quarter_select_dropdown = true
    
    # changes the display to have checkboxes that are used to migrate positions
    if params[:quarter_from]
      @migrate_to_current_quarter = true
      @quarter_to_migrate_to = Quarter.find_by_abbrev(params[:quarter_from])
      
      already_copied = @quarter_to_migrate_to.service_learning_positions.for_unit(@unit).collect{|p| p.previous_service_learning_position_id}.compact
      
      @service_learning_positions = @service_learning_positions.reject{|p| already_copied.include?(p.id)}
      
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_learning_positions }
    end
  end
  
  # Used to migrate pipeline positions to a different quarter
  def migrate_to_current_quarter
    @quarter_to_migrate_to = Quarter.find_by_abbrev(params[:quarter_from])
    
    @service_learning_positions = ServiceLearningPosition.find(params[:position_ids])
    
    @organization_quarter = nil
    @service_learning_positions.each do |service_learning_position|
      @organization_quarter = OrganizationQuarter.find(:first, 
                                   :conditions => {:organization_id => service_learning_position.organization.id,
                                                   :quarter_id => @quarter_to_migrate_to.id,
                                                   :unit_id => @unit.id})
      if @organization_quarter.nil?
        @organization_quarter = OrganizationQuarter.create( 
                                    :organization_id => service_learning_position.organization.id,
                                    :quarter_id => @quarter_to_migrate_to.id,
                                    :unit => @unit )
      end
      
      new_position = service_learning_position.clone(['details','times','supervisor','location','pipeline_position', 'approved', 'ideal_number_of_slots'])
      new_position.update_attribute(:organization_quarter_id, @organization_quarter.id)
      
      new_position.save
    end
    
    redirect_to :action => "index", :quarter_abbrev => params[:quarter_from]
  end
  
  # 
  # # GET /service_learning_positions/1
  # # GET /service_learning_positions/1.xml
  # def show
  #   @service_learning_position = ServiceLearningPosition.find(params[:id])
  #   session[:breadcrumbs].add "Positions", service_learning_positions_path
  #   session[:breadcrumbs].add @service_learning_position.title
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @service_learning_position }
  #   end
  # end
  # 
  # # GET /service_learning_positions/new
  # # GET /service_learning_positions/new.xml
  # def new
  #   @service_learning_position = ServiceLearningPosition.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @service_learning_position }
  #   end
  # end
  # 
  # # GET /service_learning_positions/1/edit
  # def edit
  #   @service_learning_position = ServiceLearningPosition.find(params[:id])
  # end
  # 
  # # POST /service_learning_positions
  # # POST /service_learning_positions.xml
  # def create
  #   @service_learning_position = ServiceLearningPosition.new(params[:service_learning_position])
  # 
  #   respond_to do |format|
  #     if @service_learning_position.save
  #       flash[:notice] = 'ServiceLearningPosition was successfully created.'
  #       format.html { redirect_to(@service_learning_position) }
  #       format.xml  { render :xml => @service_learning_position, :status => :created, :location => @service_learning_position }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @service_learning_position.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # PUT /service_learning_positions/1
  # # PUT /service_learning_positions/1.xml
  # def update
  #   @service_learning_position = ServiceLearningPosition.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @service_learning_position.update_attributes(params[:service_learning_position])
  #       flash[:notice] = "Position \"#{@service_learning_position.title rescue nil}\" sucessfully updated."
  #       format.html { redirect_to service_learning_position_path(@unit, @quarter, @service_learning_position) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @service_learning_position.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /service_learning_positions/1
  # # DELETE /service_learning_positions/1.xml
  # def destroy
  #   @service_learning_position = ServiceLearningPosition.find(params[:id])
  #   @service_learning_position.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(service_learning_positions_url) }
  #     format.xml  { head :ok }
  #   end
  # end
  
  private
  
  def service_learning_positions_breadcrumbs
    session[:breadcrumbs].add "Positions", service_learning_positions_path
  end
end
