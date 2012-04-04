class Admin::Events::TimesController < Admin::EventsController
  
  before_filter :fetch_event
  
  def index
    @times = @event.times.find :all, :order => "start_time"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @times }
    end
  end

  def show
    @time = @event.times.find(params[:id])
    @invitees = @time.invitees
    #@invitees = @invitees.sort{|x,y| (y.attending? ? 1 : 0) <=> (x.attending? ? 1 : 0) }
    #@invitees = @invitees.sort!{|x,y| (y.sub_time_id || 0) <=> (x.sub_time_id || 0)} if params[:sort_by] == 'sub_time_id'
    session[:breadcrumbs].add "#{@time.time_detail}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @time }
    end
  end

  def new
    @time = @event.times.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @time }
    end
  end

  def edit
    @time = @event.times.find(params[:id])
    session[:breadcrumbs].add "#{@time.time_detail}", event_time_url(@event, @time)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @time = @event.times.new(params[:time])

    respond_to do |format|
      if @time.save
        flash[:notice] = "Successfully created new time slot for #{@event.title}."
        format.html { redirect_to(event_time_url(@event, @time)) }
        format.xml  { render :xml => @time, :status => :created, :location => @time }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @time.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @time = @event.times.find(params[:id])

    respond_to do |format|
      if @time.update_attributes(params[:time])
        flash[:notice] = 'Successfully updated time slot.'
        format.html { redirect_to(event_time_url(@event, @time)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @time.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @time = @event.times.find(params[:id])
    @time.destroy

    respond_to do |format|
      format.html { redirect_to(event_times_url(@event)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_event
    @event = Event.find(params[:event_id])
    session[:breadcrumbs].add "#{@event.title}", @event
    session[:breadcrumbs].add "Times", event_times_url(@event)
  end
  
end