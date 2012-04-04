class Admin::Events::StaffPositionsController < Admin::EventsController
  
  before_filter :fetch_event

  def index
    @staff_positions = @event.staff_positions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @staff_positions }
    end
  end

  def show
    @staff_position = @event.staff_positions.find(params[:id])
    session[:breadcrumbs].add "#{@staff_position.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff_position }
    end
  end

  def new
    @staff_position = @event.staff_positions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff_position }
    end
  end

  def edit
    @staff_position = @event.staff_positions.find(params[:id])
    session[:breadcrumbs].add "#{@staff_position.title}", event_staff_position_path(@event, @staff_position)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @staff_position = @event.staff_positions.new(params[:staff_position])

    respond_to do |format|
      if @staff_position.save
        flash[:notice] = "#{@staff_position.title} was successfully created."
        format.html { redirect_to(event_staff_position_path(@event, @staff_position)) }
        format.xml  { render :xml => @staff_position, :status => :created, :location => event_staff_position_path(@event, @staff_position) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff_position.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @staff_position = @event.staff_positions.find(params[:id])

    respond_to do |format|
      if @staff_position.update_attributes(params[:staff_position])
        flash[:notice] = "#{@staff_position.title} was successfully updated."
        format.html { redirect_to(event_staff_position_path(@event, @staff_position)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff_position.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @staff_position = @event.staff_positions.find(params[:id])
    @staff_position.destroy

    respond_to do |format|
      format.html { redirect_to(event_staff_positions_url(@event)) }
      format.xml  { head :ok }
    end
  end

  protected
  
  def fetch_event
    @event = Event.find(params[:event_id])
    session[:breadcrumbs].add "#{@event.title}", @event
    session[:breadcrumbs].add "Staff Positions", event_staff_positions_url(@event)
  end
  
end