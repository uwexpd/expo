class Admin::Events::Times::InviteesController < Admin::Events::TimesController
  
  before_filter :fetch_time
  before_filter :add_invitees_breadcrumbs
  
  def index
    @invitees = @time.invitees
  
    respond_to do |format|
      format.html
      format.xls  { render :template => 'admin/events/attendees', :layout => 'basic' }
      format.xml  { render :xml => @invitees }
    end
  end
  
  # def show
  #   @invitee = @time.invitees.find(params[:id])
  #   @invitees = @invitee.attendees
  #   session[:breadcrumbs].add "#{@invitee.time_detail}"
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @invitee }
  #   end
  # end
  # 
  # def new
  #   @invitee = @time.invitees.new
  #   session[:breadcrumbs].add "New"
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @invitee }
  #   end
  # end
  # 
  # def edit
  #   @invitee = @time.invitees.find(params[:id])
  #   session[:breadcrumbs].add "#{@invitee.time_detail}", event_time_invitee_url(@event, @time, @invitee)
  #   session[:breadcrumbs].add "Edit"
  # end
  # 
  # def create
  #   @invitee = @time.invitees.new(params[:invitee])
  #   @invitee.event_id = @event.id
  # 
  #   respond_to do |format|
  #     if @invitee.save
  #       flash[:notice] = "Successfully created new sub-time slot for #{@event.title}."
  #       format.html { redirect_to(event_time_invitee_url(@event, @time, @invitee)) }
  #       format.xml  { render :xml => @invitee, :status => :created, :location => @invitee }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @invitee.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  def update
    @invitee = @time.invitees.find(params[:id])
    
    @use_pipeline_links = params[:from_pipeline] ? true : false
    @index_id = params[:index_id] if params[:index_id]
    @order = params[:order] ? params[:order] : 1
    
    respond_to do |format|
      if @invitee.update_attributes(params[:invitee])

        @invitees = @time.invitees.sort
        @invitees = @invitees.sort{|x,y| (y.attending? ? 1 : 0) <=> (x.attending? ? 1 : 0) }
        @invitees = @invitees.sort!{|x,y| (y.sub_time_id || 0) <=> (x.sub_time_id || 0)} if params[:sort_by] == 'sub_time_id'

        flash[:notice] = 'Successfully updated invitee.'
        format.html { redirect_to(event_time_url(@event, @time)) }
        format.js
        # format.xml  { head :ok }
      else
        # format.html { render :action => "edit" }
        # format.xml  { render :xml => @invitee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @invitee = @time.invitees.find(params[:id])
    
    # this should remove the pipeline orientation timestamp from the user record if 
    # they are removed from the pipeline orientation they atteneded
    if !@invitee.person.nil? && @time.start_time == @invitee.person.pipeline_orientation
      if @event.event_type.title == "Orientation" && @event.unit.abbreviation == "pipeline" 
        @invitee.person.update_attribute(:pipeline_orientation, nil)
      end
    end
    
    @invitee.destroy

    respond_to do |format|
      format.html { redirect_to(event_time_url(@event, @time)) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_time
    @time = @event.times.find(params[:time_id])
    session[:breadcrumbs].add "#{@time.time_detail}", event_time_url(@event, @time)
  end
  
  def add_invitees_breadcrumbs
    session[:breadcrumbs].add "Invitees", event_time_invitees_url(@event, @time)
  end
  
end