class Admin::EquipmentReservationsController < Admin::BaseController

  before_filter :add_equipment_reservations_breadcrumbs, :except => [:staff, :staff_reserve]
  before_filter :add_equipment_breadcrumbs, :only => [:staff, :staff_reserve]
  before_filter :assign_status_class, :except => [:staff, :staff_reserve]
  
  skip_before_filter :login_required, :admin_required, :check_ferpa_reminder_date, :add_to_session_history, :save_user_in_current_thread, :only => ['current_checkout_viewing']

  def index
    @equipment_reservations = {}
    @unit = Unit.find(params[:unit_id]) if params[:unit_id]
    conditions = { :status => %w[pending approved late checked_out] }
    conditions.merge!({ :unit_id => @unit.id }) if @unit
    
    EquipmentReservation.find(:all, :conditions => conditions).each do |r|
      unless r.status == :approved && r.start_date < Time.now.midnight
        @equipment_reservations[r.status] ||= []
        @equipment_reservations[r.status] << r 
      end
    end
    
    session[:breadcrumbs].add "#{@unit.title}" if @unit
  end

  def all
    @unit = Unit.find(params[:unit_id]) if params[:unit_id]
    conditions = { :unit_id => @unit.id } if @unit
    @equipment_reservations = EquipmentReservation.paginate(:all, :conditions => conditions, :page => params[:page])
    session[:breadcrumbs].add "All Reservations", all_equipment_reservations_path

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @equipment_reservations }
    end
  end
  
  def todays_checkouts
    @equipment_reservations = EquipmentReservation.todays_checkouts.paginate(:page => params[:page])
    session[:breadcrumbs].add "Today's Checkouts"
    render :action => "all"
  end

  def todays_checkins
    @equipment_reservations = EquipmentReservation.todays_checkins.paginate(:page => params[:page])
    session[:breadcrumbs].add "Today's Check-ins"
    render :action => "all"
  end

  def tomorrows_checkouts
    @equipment_reservations = EquipmentReservation.tomorrows_checkouts.paginate(:page => params[:page])
    session[:breadcrumbs].add "Tomorrow's Checkouts"
    render :action => "all"
  end

  def tomorrows_checkins
    @equipment_reservations = EquipmentReservation.tomorrows_checkins.paginate(:page => params[:page])
    session[:breadcrumbs].add "Tomorrow's Check-ins"
    render :action => "all"
  end

  def late_returns
    @equipment_reservations = EquipmentReservation.late_returns.paginate(:page => params[:page])
    session[:breadcrumbs].add "Late Returns"
    render :action => "all"
  end

  def policies
    render :action => "policies", :layout => 'popup'
  end

  def unit
    @unit = Unit.find(params[:unit_id] || params[:id])
    @equipment_reservations = EquipmentReservation.paginate(:all, :page => params[:page], :conditions => { :unit_id => @unit.id })
    session[:breadcrumbs].add "#{@unit.title}"
    render :action => "index"
  end

  def show
    @equipment_reservation = EquipmentReservation.find(params[:id])
    @student = @equipment_reservation.person
    session[:breadcrumbs].add "Reservation ##{@equipment_reservation.id_s}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @equipment_reservation }
    end
  end
  
  def new
    @equipment_reservation = EquipmentReservation.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @equipment_reservation }
    end
  end
  
  def create
    @equipment_reservation = EquipmentReservation.new(params[:equipment_reservations])

    respond_to do |format|
      if @equipment_reservation.save
        flash[:notice] = "Successfully created equipment reservation."
        format.html { redirect_to equipment_reservation_path(@equipment_reservation) }
        format.xml  { render :xml => @equipment_reservation, :status => :created, 
                             :location => equipment_reservation_path(@equipment_reservation) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @equipment_reservation.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @equipment_reservation = EquipmentReservation.find(params[:id])
    session[:breadcrumbs].add "Reservation ##{@equipment_reservation.id_s}", equipment_reservation_path(@equipment_reservation)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @equipment_reservation = EquipmentReservation.find(params[:id])

    respond_to do |format|
      if @equipment_reservation.update_attributes(params[:equipment_reservations])
        flash[:notice] = "Successfully updated equipment reservation."
        format.html { redirect_to equipment_reservation_path(@equipment_reservation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @equipment_reservation.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @equipment_reservation = EquipmentReservation.find(params[:id])
    @equipment_reservation.destroy
    flash[:notice] = "Successfully destroyed equipment reservation."
    respond_to do |format|
      format.html { redirect_to equipment_reservations_url(@equipment_reservation) }
      format.xml  { head :ok }
      format.js
    end
  end

  def unit
    @unit = Unit.find params[:id]
    @equipment_reservations = EquipmentReservation.paginate(:all, :page => params[:page], :conditions => { :unit_id => @unit.id })
    session[:breadcrumbs].add "#{@unit.title}"
    render :action => "index"
  end
  
  def approve
    @equipment_reservation = EquipmentReservation.find(params[:id])
    if @current_user.has_role?(:equipment_reservation_approver, @equipment_reservation.unit)
      @equipment_reservation.update_attributes(:approver_id => @current_user.id, :approved_at => Time.now)
    else
      return render :template => "exceptions/permission_denied", :status => :unauthorized
    end
    
    respond_to do |format|
      format.html { redirect_to :action => "show" }
      format.js
    end
  end
  
  def checkout
    @equipment_reservation = EquipmentReservation.find(params[:id])
    @student = @equipment_reservation.person
    
    unless @equipment_reservation.status == :approved
      flash[:error] = "That reservation is not ready for checkout."
      return redirect_to :action => 'show'
    end

    unless @equipment_reservation.start_date.today?
      flash[:error] = "You can't checkout that equipment until the start date of the reservation."
      return redirect_to :action => "show"
    end

    @equipment_reservation.save_as_current_checkout_viewing

    if request.put?
      @equipment_reservation.validate_checkout = true
      @equipment_reservation.checkout_user_id = @current_user.try(:id)
      @equipment_reservation.checked_out_at = Time.now
      if @equipment_reservation.update_attributes(params[:equipment_reservation])
        EquipmentReservation.clear_current_checkout_viewing!
        return redirect_to :action => "show"
      end
    end
    
    session[:breadcrumbs].add "Reservation ##{@equipment_reservation.id_s}", equipment_reservation_path(@equipment_reservation)
    session[:breadcrumbs].add "Checkout"
  end
  
  def checkin
    @equipment_reservation = EquipmentReservation.find(params[:id])
    @student = @equipment_reservation.person

    unless [:checked_out, :late].include?(@equipment_reservation.status)
      flash[:error] = "That reservation is not ready for check-in."
      return redirect_to :action => 'show'
    end

    if request.put?
      @equipment_reservation.validate_checkin = true
      @equipment_reservation.checkin_user_id = @current_user.try(:id)
      @equipment_reservation.checked_in_at = Time.now
      if @equipment_reservation.update_attributes(params[:equipment_reservation])
        # other tasks:
        #  - if late, put a restriction on student record
        #  - if damaged/bad, send an email
        #  - for laptops, uncheck "ready for checkout" and kick off re-image
        return redirect_to :action => "show"
      end
    end
    
    session[:breadcrumbs].add "Reservation ##{@equipment_reservation.id_s}", equipment_reservation_path(@equipment_reservation)
    session[:breadcrumbs].add "Check-in"
  end

  def about
    @equipment = Equipment.find params[:id]
    render :template => 'equipment_reservation/about', :layout => "popup"
  end

  def current_checkout_viewing
    return render :text => 'access denied' unless params[:t] == "QzMhM2vPSU5eJpsq"
    @equipment_reservation = EquipmentReservation.current_checkout_viewing
    @close_button = false
    
    respond_to do |format|
      format.html { render :action => 'current_checkout_viewing', :layout => 'popup' }
      format.js   { render :partial => 'current_checkout' }
    end
  end

  def assign_status_class
    @status_class ||= {
    	:in_progress => "unavailable",
    	:pending => "blue-background",
    	:approved => "green-background",
    	:checked_out => "approved",
    	:returned => "",
    	:late => "red-background",
    	:returned_damaged => "red-background"
    }
  end  

  def staff
    @current_reservations = @current_user.person.equipment_reservations.submitted.select{|e| e.end_date > Time.now }
    @in_progress_reservations = @current_user.person.equipment_reservations.in_progress
    @past_reservations = @current_user.person.equipment_reservations.submitted.select{|e| e.end_date < Time.now }
    
    session[:breadcrumbs].add "Staff Reservation"
  end
  
  def staff_create            
    @reservation = @current_user.person.equipment_reservations.new(params[:reservation])
    @reservation.staff = true if @current_user.admin?
    @reservation.unit = Unit.find_by_abbreviation("EXP")

    if @reservation.save
       redirect_to :action => "staff_reserve", :id => @reservation
    else
       flash[:error] = "There was an error processing your reservation. Please try again." 
       render :action => "staff"
    end         
  end
  
  def staff_reserve        
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    @reservation.update_attributes(params[:reservation]) if params[:reservation]
        
    if params[:equipment_id]
      @success = @reservation.add_or_remove!(params[:equipment_id])
    else
      @success = true
    end    
    
    @reservation.remove_disallowed_items! unless @success == false
    
    session[:breadcrumbs].add "Staff Reservation", :action => 'staff'
    session[:breadcrumbs].add "Reserve"
    
    # TODO Error message won't show up...
    # if params[:reservation] && ((@reservation.end_date - @reservation.start_date)/60).to_i <= 30       
    #   @reservation.errors.add_to_base "The internal between start time and end time needs at least 30 minutes."
    #   @success = false
    # end    
    #logger.debug "Debug => #{@reservation.errors.full_messages}"
        
    respond_to do |format|
      format.html
      format.js
    end        
  end

  # Finalize the reservation and send it off for approval
  def finalize
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    # if @reservation.submitted?
    #   flash[:error] = "This reservation is already submitted, so you cannot change the details of it."
    #   return redirect_to :action => "staff"
    # end
    
    @reservation.submitted = true
        
    if @reservation.valid? && @reservation.save!      
      flash[:notice] = "Thank you for submitting your reservation ##{@reservation.id}"
      redirect_to :action => "staff"
    else
      flash[:error] = "There was an error processing your reservation. Please try again."
      redirect_to :action => "staff_reserve", :id => @reservation
    end
  end  
  

  protected

  def add_equipment_reservations_breadcrumbs
    session[:breadcrumbs].add "Equipment Reservations", equipment_reservations_path
  end
  
  def add_equipment_breadcrumbs
    session[:breadcrumbs].add "Equipment", equipments_path
  end

end
