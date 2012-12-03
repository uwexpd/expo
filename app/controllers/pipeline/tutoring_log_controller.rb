class Pipeline::TutoringLogController < PipelineController
  skip_before_filter :fetch_favorite_ids
  before_filter :fetch_course_abbrev
  before_filter :fetch_placement
  before_filter :add_tutoring_breadcrumbs, :only => [:index, :show, :new, :edit]

  def index        
    @tutoring_logs = @placement.tutoring_logs    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tutoring_logs }
    end        
  end

  def show
    @log ||= @placement.tutoring_logs.find(params[:id])
    session[:breadcrumbs].add "Show"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @log }
    end
  end
  
  def new
    @log ||= @placement.tutoring_logs.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @log }
    end
  end

  def edit
    @log ||= @placement.tutoring_logs.find(params[:id])
    session[:breadcrumbs].add "#{@log.log_date}", pipeline_tutoring_path(@quarter.abbrev, @course_abbrev, @placement)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @log ||= @placement.tutoring_logs.new(params[:log])

    respond_to do |format|
      if @log.save
        flash[:notice] = "Date #{@log.log_date} tutoring log was successfully created."
        format.html { redirect_to :action => 'index' }
        format.xml  { render :xml => @log, :status => :created, :location => @log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @log.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @log ||= @placement.tutoring_logs.find(params[:id])

    respond_to do |format|
      if @log.update_attributes(params[:log])
        flash[:notice] = "Date #{@log.log_date} tutoring log was successfully update."
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @log.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @log ||= @placement.tutoring_logs.find(params[:id])
    @log.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
      format.js
    end
  end

  def submit
     @placement.update_attribute(:tutoring_submitted_at, Time.now)
     flash[:notice] = "You have submitted your tutoring logs."
     return redirect_to :action => "index"
  end
  
  protected
  
  def add_tutoring_breadcrumbs
    session[:breadcrumbs].add "Tutoring Log", pipeline_tutoring_path(@quarter.abbrev, @course_abbrev, @placement)
  end
  
  def fetch_placement
    @placement = ServiceLearningPlacement.find(params[:placement])
  end

  def fetch_course_abbrev
    @course_abbrev = params[:course_abbrev]
  end
end