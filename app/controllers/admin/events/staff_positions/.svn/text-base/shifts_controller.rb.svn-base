class Admin::Events::StaffPositions::ShiftsController < Admin::Events::StaffPositionsController
  
  before_filter :fetch_staff_position

  def index
    @shifts = @staff_position.shifts.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shifts }
    end
  end

  def show
    @shift = @staff_position.shifts.find(params[:id])
    session[:breadcrumbs].add "#{@shift.time_detail}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shift }
    end
  end

  def new
    @shift = @staff_position.shifts.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shift }
    end
  end

  def edit
    @shift = @staff_position.shifts.find(params[:id])
    session[:breadcrumbs].add "#{@shift.time_detail}", event_staff_position_shift_path(@event, @staff_position, @shift)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @shift = @staff_position.shifts.new(params[:shift])

    respond_to do |format|
      if @shift.save
        flash[:notice] = "#{@shift.time_detail} was successfully created."
        format.html { redirect_to(event_staff_position_shift_path(@event, @staff_position, @shift)) }
        format.xml  { render :xml => @shift, :status => :created, :location => event_staff_position_shift_path(@event, @staff_position, @shift) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @shift = @staff_position.shifts.find(params[:id])

    respond_to do |format|
      if @shift.update_attributes(params[:shift])
        flash[:notice] = "#{@shift.time_detail} was successfully updated."
        format.html { redirect_to(event_staff_position_shift_path(@event, @staff_position, @shift)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @shift = @staff_position.shifts.find(params[:id])
    @shift.destroy

    respond_to do |format|
      format.html { redirect_to(event_staff_position_url(@event, @staff_position)) }
      format.xml  { head :ok }
    end
  end

  protected
  
  def fetch_staff_position
    @staff_position = @event.staff_positions.find(params[:staff_position_id])
    session[:breadcrumbs].add @staff_position.title, event_staff_position_url(@event, @staff_position)
    session[:breadcrumbs].add "Shifts", event_staff_position_shifts_path(@event, @staff_position)
  end
  
end