class Admin::Offerings::SessionsController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_statuses_breadcrumbs

  def index
    @sessions = @offering.sessions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sessions }
    end
  end

  def show
    @session = @offering.sessions.find(params[:id])
    session[:breadcrumbs].add "#{@session.title}"
    @presenters = @session.presenters.sort_by(&:lastname_first)
    @presenters = @session.presenters.sort{|x,y| x.location_section_id.to_s <=> y.location_section_id.to_s} if @session.uses_location_sections?
    @presenters = @presenters.sort{|x,y| (x.instance_eval(params[:sort_by]).to_s) <=> (y.instance_eval(params[:sort_by]).to_s)} if params[:sort_by]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @session }
    end
  end

  def new
    @session = @offering.sessions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @session }
    end
  end

  def edit
    @session = @offering.sessions.find(params[:id])
    session[:breadcrumbs].add "#{@session.title}", offering_session_path(@offering, @session)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @session = @offering.sessions.new(params[:session])

    respond_to do |format|
      if @session.save
        flash[:notice] = 'Session was successfully created.'
        format.html { redirect_to(offering_session_url(@offering, @session)) }
        format.xml  { render :xml => @session, :status => :created, :location => @session }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @session.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @session = @offering.sessions.find(params[:id])

    respond_to do |format|
      if @session.update_attributes(params[:session])
        flash[:notice] = 'OfferingSession was successfully updated.'
        format.html { redirect_to(offering_session_url(@offering, @session)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @session.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @session = @offering.sessions.find(params[:id])
    @session.destroy

    respond_to do |format|
      format.html { redirect_to(offering_sessions_url(@offering)) }
      format.xml  { head :ok }
    end
  end

  def add_presenter
    @session = @offering.sessions.find(params[:id])
    @app = @offering.application_for_offerings.find(params[:presenter][:app_id]) rescue nil
    
    if @app.nil?
      error = "Could not find an application with that ID."
    elsif @session.presenters.include?(@app)
      error = "That presenter is already part of this session."
    elsif @app.update_attribute(:offering_session_id, @session.id)
      flash[:notice] = "Successfully added presenter to session."
    else
      error = "Error adding presenter to session."
    end
    
    @presenters = @session.presenters.sort_by(&:lastname_first)
    @presenters = @session.presenters.sort{|x,y| x.location_section_id.to_s <=> y.location_section_id.to_s} if @session.uses_location_sections?
    @presenters = @presenters.sort{|x,y| (x.instance_eval(params[:sort_by]).to_s) <=> (y.instance_eval(params[:sort_by]).to_s)} if params[:sort_by]
        
    respond_to do |format|
      if error
        format.html { redirect_to offering_session_url(@offering, @session) }
        format.js   { render :text => error, :status => 501 }
      else
        format.html { redirect_to offering_session_url(@offering, @session) }
        format.js   { render :partial => 'presenters' }
      end
    end
  end
  
  def remove_presenter
    @session = @offering.sessions.find(params[:id])
    @app = @offering.application_for_offerings.find(params[:app_id])
    
    respond_to do |format|
      if @app.update_attribute(:offering_session_id, nil)
        @presenters = @session.presenters.sort_by(&:lastname_first)
        @presenters = @session.presenters.sort{|x,y| x.location_section_id.to_s <=> y.location_section_id.to_s} if @session.uses_location_sections?
        @presenters = @presenters.sort{|x,y| (x.instance_eval(params[:sort_by]).to_s) <=> (y.instance_eval(params[:sort_by]).to_s)} if params[:sort_by]

        flash[:notice] = "Successfully removed presenter from session."
        format.html { redirect_to offering_session_url(@offering, @session) }
        format.js   { render :partial => 'presenters' }
      else
        flash[:error] = "Error removing presenter from session."
        format.html { redirect_to offering_session_url(@offering, @session) }
        format.js   { render :text => "Error removing presenter", :status => 501 }
      end
    end    
  end

  def disciplines
    @sessions = @offering.sessions.for_type(params[:application_type_id])
    @sections = @offering.location_sections
    @apps = @offering.application_for_offerings.with_status(:confirmed)
    @departments = {}
    @running_total = {}
    apps = @apps.select{|a| @sessions.include?(a.offering_session)}
#    apps = apps.select{|a| a.mentor_department == params[:department]} if params[:department]
    for app in apps
      dept = app.mentor_department.to_s
      sess = app.offering_session
      section = app.location_section
      @running_total[sess] ||= {}
      @running_total[sess][:total] ||= []
      @running_total[sess][section] ||= []
      @running_total[sess][:total] << app
      @running_total[sess][section] << app
      if !params[:department] || app.mentor_department == params[:department]
        @departments[dept] ||= {}
        @departments[dept][sess] ||= {}
        @departments[dept][sess][section] ||= []
        @departments[dept][sess][:total] ||= []
        @departments[dept][sess][section] << app
        @departments[dept][sess][:total] << app
      end
    end
    session[:breadcrumbs].add "Discipline Breakdown"
    
    respond_to do |format|
      format.html
      format.js   { render :action => "disciplines", :layout => false }
    end
  end

  def easels
    @session = @offering.sessions.find params[:id]
    @application_type = @session.application_type
    @location_sections = @offering.location_sections
    @sessions = @application_type.offering_sessions
    session[:breadcrumbs].add "Easel Arrangement"
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_statuses_breadcrumbs
    session[:breadcrumbs].add "Sessions", offering_sessions_path(@offering)
  end
  
end