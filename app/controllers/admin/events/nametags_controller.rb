class Admin::Events::NametagsController < Admin::EventsController
  before_filter :fetch_event

  def index
  end
  
  def attendees
    @attendees = @event.attendees.sort
    # FIXME: Don't just use #sort here -- it causes weird problems when you have ApplicationForOfferings and ApplicationGroupMembers
    # in the same set.
    
    session[:breadcrumbs].add "Attendees"

    respond_to do |format|
      format.html
      format.pdf
    end
  end
  
  def staff_position
    @staff_position = @event.staff_positions.find params[:id]
    @people = @staff_position.shifts.collect(&:people).flatten.uniq.compact.sort
    session[:breadcrumbs].add "Staff Position"

    respond_to do |format|
      format.pdf
    end
  end
  
  def other
    if params[:event]
      @event.update_attribute(:other_nametags, params[:event][:other_nametags]) 
      flash[:notice] = "Successfully saved your custom nametags."
      redirect_to :action => "other" and return
    end
    session[:breadcrumbs].add "Other"

    respond_to do |format|
      format.html
      format.pdf  { @nametags = @event.other_nametags }
    end
  end
  
  private
  
  def fetch_event
    @event = Event.find(params[:event_id])
    session[:breadcrumbs].add "#{@event.title}", event_path(@event)
    session[:breadcrumbs].add "Nametags", event_nametags_path(@event)
  end
  
end