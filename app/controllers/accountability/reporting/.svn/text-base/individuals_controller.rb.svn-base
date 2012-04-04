class Accountability::Reporting::IndividualsController < Accountability::ReportingController
  before_filter :add_individuals_breadcrumbs
  before_filter :check_finalized, :only => [:upload, :upload_map, :upload_create, :new, :create, :edit, :update, :destroy]
  skip_before_filter :fetch_service_learning_courses
  
  def index
    @activities = {}
    for activity_type in @activity_types
      @activities[activity_type.id] = ActivityProject.for_quarter(@quarters).for_department(@department).of_type(activity_type).find(:all, :include => [:quarters])
    end
  end

  def upload
    session[:breadcrumbs].add "Upload"
  end
  
  def upload_map
    if request.put?
      if params[:upload] && params[:upload][:file]
        @file = ActivityProjectUploadedFile.new(params[:upload][:file], @department, @year, @quarters)
        @file.contents
      else
        flash[:error] = "You must choose a file to upload."
        render :action => "upload" and return
      end
    else
      redirect_to :action => "index" and return
    end
    session[:breadcrumbs].add "Upload"
    
  rescue Ole::Storage::FormatError
    flash[:error] = "Invalid file format. Please upload a Microsoft Excel file in 97-2003 format (.xls file extension)."
    redirect_to :action => "upload" and return
  end
  
  def upload_create
    @file = ActivityProjectUploadedFile.new(params[:filename], @department, @year, @quarters)
    @file.column_mapping = params[:heading_map]
    @file.hours_are_totals = params[:hours_are_totals]
    if @file.valid_column_mapping?
      @errors, @success = @file.import_records!
      flash[:notice] = "Successfully added #{@success.size} record(s)." unless @success.empty?
      flash[:error] = "Could not add these #{@errors.size} record(s): <ul>#{@errors.collect{|r| "<li>" + r.join(", ") + "</li>"}}</ul>" unless @errors.empty?
      redirect_to :action => "index", :success_ids => @success.collect(&:id)
    else
      flash[:error] = "You must select a matching column in your upload file for all required fields. Please try again."
      render :action => "upload_map"
    end
    session[:breadcrumbs].add "Upload"
  end

  def show
    redirect_to :action => "edit"
    # session[:breadcrumbs].add "#{@activity.title}"
    #   
    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @activity }
    # end
  end

  def new
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  def edit
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).find(params[:id])
    session[:breadcrumbs].add "#{@activity.id}", accountability_reporting_individual_path(@year, @activity)
    session[:breadcrumbs].add "Edit"
  end

  def create
    attributes = params[:activity]
    attributes[:department_id] = @department.dept_code unless @department.dept_code.blank?
    attributes[:department_name] = @department.fixed_name if @department.dept_code.blank?
    attributes[:preparer_uw_netid] = current_user.login
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).new(attributes)

    # Check that they submitted at least one quarter
    quarter_vals = params[:quarter_hours].values.compact.uniq
    if quarter_vals.empty? || (quarter_vals.size == 1 && quarter_vals.first.blank?)
      @quarters_error = "You must specify at least one quarter of involvement."
    end

    respond_to do |format|
      if !@quarters_error && @activity.save
        for quarter in @quarters
          unless params[:quarter_hours][quarter.id.to_s].blank?
            aq = @activity.quarters.find_or_create_by_quarter_id(quarter.id)
            attribute_to_update = params[:quarter_calculation][quarter.id.to_s] || "number_of_hours"
            attribute_to_reset = attribute_to_update == "number_of_hours" ? "hours_per_week" : "number_of_hours"
            aq.update_attribute(attribute_to_update, params[:quarter_hours][quarter.id.to_s])
            aq.update_attribute(attribute_to_reset, nil)
          end
        end
        flash[:notice] = "Activity was successfully created."
        format.html { redirect_to(accountability_reporting_individuals_path(@year, :success_ids => [@activity.id])) }
        format.xml  { render :xml => @activity, :status => :created, :location => accountability_reporting_individual_path(@year, @activity) }
      else
        @activity.errors.add_to_base @quarters_error if @quarters_error

        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).find(params[:id])
    attributes = params[:activity]
    attributes[:preparer_uw_netid] = current_user.login

    respond_to do |format|
      if @activity.update_attributes(attributes)
        
        for quarter in @quarters
          unless params[:quarter_hours][quarter.id.to_s].blank?
            aq = @activity.quarters.find_or_create_by_quarter_id(quarter.id)
            attribute_to_update = params[:quarter_calculation][quarter.id.to_s] || "number_of_hours"
            attribute_to_reset = attribute_to_update == "number_of_hours" ? "hours_per_week" : "number_of_hours"
            aq.update_attribute(attribute_to_update, params[:quarter_hours][quarter.id.to_s])
            aq.update_attribute(attribute_to_reset, nil)
          end
        end
        
        flash[:notice] = "Activity was successfully updated."
        format.html { redirect_to(accountability_reporting_individuals_path(@year)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to(accountability_reporting_individuals_path(@year)) }
      format.xml  { head :ok }
      format.js
    end
  end

  def student_search
    val = params[:student_id]
    @student = nil if val.blank?
    @student = val.to_i != 0 ? StudentRecord.find_by_student_no("#{val}") : StudentRecord.find_by_uw_netid("#{val}") rescue nil
    
    respond_to do |format|
      format.js
    end
  end

  def individual_reporting_template
    respond_to do |format|
      format.xls { render :action => 'individual_reporting_template', :layout => nil }
    end
  end

  protected
  
  def add_individuals_breadcrumbs
    session[:breadcrumbs].add "Individuals", accountability_reporting_individuals_url(@year)
  end
end