class Admin::Events::Times::SubTimesController < Admin::Events::TimesController
  
  before_filter :fetch_time
  before_filter :add_sub_time_breadcrumbs
  
  def index
    @sub_times = @time.sub_times.find :all, :order => "start_time"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sub_times }
    end
  end

  def show
    @sub_time = @time.sub_times.find(params[:id])
    @invitees = @sub_time.attendees
    session[:breadcrumbs].add "#{@sub_time.time_detail}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sub_time }
    end
  end

  def new
    @sub_time = @time.sub_times.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sub_time }
    end
  end

  def edit
    @sub_time = @time.sub_times.find(params[:id])
    session[:breadcrumbs].add "#{@sub_time.time_detail}", event_time_sub_time_url(@event, @time, @sub_time)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @sub_time = @time.sub_times.new(params[:sub_time])
    @sub_time.event_id = @event.id

    respond_to do |format|
      if @sub_time.save
        flash[:notice] = "Successfully created new sub-time slot for #{@event.title}."
        format.html { redirect_to(event_time_sub_time_url(@event, @time, @sub_time)) }
        format.xml  { render :xml => @sub_time, :status => :created, :location => @sub_time }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sub_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @sub_time = @time.sub_times.find(params[:id])

    respond_to do |format|
      if @sub_time.update_attributes(params[:sub_time])
        flash[:notice] = 'Successfully updated time slot.'
        format.html { redirect_to(event_time_sub_time_url(@event, @time, @sub_time)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sub_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @sub_time = @time.sub_times.find(params[:id])
    @sub_time.destroy

    respond_to do |format|
      format.html { redirect_to(event_time_sub_times_url(@event, @time)) }
      format.xml  { head :ok }
    end
  end
  
  def add_to_sub_time
    @invitee = @time.invitees.find params[:invitee_id]
    @sub_time = @time.sub_times.find params[:id][/^(.+)_(\d+)$/,2]
    respond_to do |format|
      @old_sub_time = @invitee.sub_time if @invitee.sub_time && @invitee.sub_time != @sub_time
      if @invitee.update_attribute(:sub_time_id, @sub_time.id)
        format.js
      else
        flash[:error] = "Could not add that person to that sub-time."
        format.js   { page.replace_html 'sub_time_error', 'test' }
      end        
      format.html { redirect_to :action => "show", :id => @sub_time }
    end
  rescue => e
    respond_to do |format|
      format.js { 
        render :update do |page| 
          page.replace_html 'sub_time_error', "Error: " + e.message
        end 
      }
    end
  end
  
  def mass_add_to_sub_time 
    @sub_time = @time.sub_times.find params[:sub_time_id] rescue nil
    sub_time_id = @sub_time.nil? ? nil : @sub_time.id
    @invitees = []
    params[:select].each do |klass,objects|
      objects.each do |id, count|
        invitee = @time.invitees.find id
        @invitees << invitee
        invitee.update_attribute(:sub_time_id, sub_time_id)
      end
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  rescue => e
    respond_to do |format|
      format.js { 
        render :update do |page| 
          page.replace_html 'sub_time_error', "Error: " + e.message
        end 
      }
    end
  end
  
  protected
  
  def fetch_time
    @time = @event.times.find(params[:time_id])
    session[:breadcrumbs].add "#{@time.time_detail}", event_time_url(@event, @time)
  end
  
  def add_sub_time_breadcrumbs
    session[:breadcrumbs].add "Sub-Times", event_time_sub_times_url(@event, @time)
  end
  
end