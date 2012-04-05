class Admin::EventsController < Admin::BaseController
  before_filter :create_event_breadcrumbs
  before_filter :check_user_unit, :except => [ :index, :auto_complete, :new, :create ]

  def index
    @units = @current_user.units rescue []
    conditions = { :unit_id => @units.collect(&:id) }
    @events = Event.paginate(:all, :order => "id DESC", 
                                  :conditions => conditions,
                                  :include => [ :event_type, :unit, :times ],
                                  :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def auto_complete
    @units = @current_user.units rescue []
    conditions = "unit_id IN (#{@units.collect(&:id).join(",")}) AND title LIKE '%#{params[:q]}%'"
    @events = Event.find(:all, :order => "id DESC", 
                                  :conditions => conditions,
                                  :include => [ :event_type, :unit, :times ])
    
    respond_to do |format|
      format.js
    end
  end

  # def all
  #   @units = :all
  #   @events = Event.find_and_sort(:all, :order => (params[:order] || "id DESC"), :include => [ :event_type, :unit ])
  #   session[:breadcrumbs].add "All"
  #   render :action => 'index'
  # end
  # 
  def show
    @event ||= Event.find(params[:id])
    session[:breadcrumbs].add "#{@event.title}"

    @new_select_value = { :value => @event.id, :title => @event.title }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    @event ||= Event.new
    session[:breadcrumbs].add "New"
	
	  @event.offering_id = params[:offering_id] if params[:offering_id]
	
    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
    @event ||= Event.find(params[:id])
    session[:breadcrumbs].add "#{@event.title}", @event
    session[:breadcrumbs].add "Edit"
  end

  def create
    @event ||= Event.new(params[:event])

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(new_event_time_path(@event)) }
        format.xml  { render :xml => @event, :status => :created, :location => new_event_time_path(@event) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @event ||= Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @event ||= Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
  
  def attendees
    @event ||= Event.find(params[:id])
    @attendees = @event.attendees
    @invitees = @event.invitees
    session[:breadcrumbs].add "#{@event.title}", event_url(@event)
    session[:breadcrumbs].add "Attendees"
    
    respond_to do |format|
      format.html
      format.xls  { render :layout => 'basic' }
    end
  end
  
  # Makes sure that all applications from this event's linked Offering are invitees for this event.
  def sync_with_offering
    @event ||= Event.find(params[:id])
    session[:breadcrumbs].add "#{@event.title}", event_url(@event)
    session[:breadcrumbs].add "Sync with Offering"
    
    unless @event.offering
      flash[:error] = "This event is not associated with an Offering. Nothing to sync."
      return redirect_to :back
    end
    
    if request.post?
      @event_time = @event.times.find(params[:event_time])
      apps = @event.offering.application_for_offerings.with_status(params[:status])
      for app in apps
        @event_time.invite!(app, :attending => true)
        app.group_members.each{|g| @event_time.invite!(g, :attending => true)}
      end
      for invitee in @event_time.invitees
        if invitee.invitable.is_a?(ApplicationForOffering) || invitee.invitable.is_a?(ApplicationGroupMember)
          invitee.update_attribute(:attending => false) if invitee.invitable.app.in_status?(:cancelled)
        end
      end
      redirect_to :action => "attendees"
    end    
  end
  
  # Copy from previous event
  def clone
    @event ||= Event.find(params[:id])
    
    if e2 = @event.deep_clone!
      flash[:notice] = "Successfully cloned #{@event.title}. You can customize the details below."
      redirect_to edit_event_path(e2)
    else
      flash[:error] = "Sorry, but we couldn't copy that event. An error occurred."
      redirect_to :back
    end
  end
  
  protected
  
  def create_event_breadcrumbs
    session[:breadcrumbs].add "Events", events_url
  end
  
  def check_user_unit
    @event = Event.find(params[:event_id] || params[:id])
    require_user_unit @event.unit
  end
  
end