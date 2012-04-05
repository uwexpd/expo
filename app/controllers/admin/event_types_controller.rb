class Admin::EventTypesController < Admin::BaseController

  before_filter :add_event_types_breadcrumbs
  
  def index
    @event_type = EventType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_type }
    end
  end
    
  def show
    @event_type = EventType.find(params[:id])
    session[:breadcrumbs].add "#{@event_type.title}"
	
	@new_select_value = { :value => @event_type.id, :title => @event_type.title }
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_type }
    end
  end
  
  def new
    @event_type = EventType.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @event_type }
    end
  end
  
  def create
    @event_type = EventType.new(params[:event_type])

    respond_to do |format|
      if @event_type.save
        flash[:notice] = "Successfully created event types."
        format.html { redirect_to event_type_path(@event_type) }
        format.xml  { render :xml => @event_type, :status => :created, 
                             :location => event_type_path(@event_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @event_type = EventType.find(params[:id])
    session[:breadcrumbs].add "#{@event_type.title}", event_type_path(@event_type)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @event_type = EventType.find(params[:id])

    respond_to do |format|
      if @event_type.update_attributes(params[:event_type])
        flash[:notice] = "Successfully updated event types."
        format.html { redirect_to event_type_path(@event_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @event_type = EventType.find(params[:id])
    @event_type.destroy
    flash[:notice] = "Successfully destroyed event types."
    respond_to do |format|
      format.html { redirect_to event_types_url }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def add_event_types_breadcrumbs
    session[:breadcrumbs].add "Event Types", event_types_path
  end

end
