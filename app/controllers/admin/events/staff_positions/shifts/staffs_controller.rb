class Admin::Events::StaffPositions::Shifts::StaffsController < Admin::Events::StaffPositions::ShiftsController
  
  before_filter :fetch_shift

  # def index
  #   @staff = @shift.staffs
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @staff }
  #   end
  # end
  # 
  # def show
  #   @staff = @shift.staffs.find(params[:id])
  #   session[:breadcrumbs].add "#{@staff.fullname}"
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @staff }
  #   end
  # end
  # 
  # def new
  #   @staff = @shift.staffs.new
  #   session[:breadcrumbs].add "New"
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @staff }
  #   end
  # end
  # 
  # def edit
  #   @staff = @shift.staffs.find(params[:id])
  #   session[:breadcrumbs].add "#{@staff.fullname}", @staff
  #   session[:breadcrumbs].add "Edit"
  # end
  # 
  # def create
  #   @staff = @shift.staffs.new(params[:staff])
  # 
  #   respond_to do |format|
  #     if @staff.save
  #       flash[:notice] = "@shift.staffs was successfully created."
  #       format.html { redirect_to(@staff) }
  #       format.xml  { render :xml => @staff, :status => :created, :location => @staff }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # def update
  #   @staff = @shift.staffs.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @staff.update_attributes(params[:staff])
  #       flash[:notice] = "@shift.staffs was successfully updated."
  #       format.html { redirect_to(@staff) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
 
  def destroy
    @staff = @shift.staffs.find(params[:id])
    
    if @staff_position.require_all_shifts?
      @staff_position.unsignup!(@staff.person)
    else
      @shift.unsignup!(@staff.person)
    end

    respond_to do |format|
      format.html { redirect_to(event_staff_position_shift_path(@event, @staff_position, @shift)) }
      format.js
      format.xml  { head :ok }
    end
  end

  protected
  
  def fetch_shift
    @shift = @staff_position.shifts.find(params[:shift_id])
    session[:breadcrumbs].add "Volunteers", event_staff_position_shift_staffs_path(@event, @staff_position, @shift)
  end
  
end