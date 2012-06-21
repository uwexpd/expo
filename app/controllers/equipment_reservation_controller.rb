class EquipmentReservationController < ApplicationController
  skip_before_filter :login_required
  before_filter :student_login_required, :except => [:policies]
  before_filter :apply_alternate_stylesheet
  before_filter :check_must_be_student_restriction, :except => [:students_only, :policies]
  before_filter :check_reservation_restrictions, :except => [:restricted, :policies]


  def index
    @current_reservations = @current_user.person.equipment_reservations.current
    @past_reservations = @current_user.person.equipment_reservations.past
  end
  
  # Start a new reservation; agree to policies
  def new
    @reservation = @current_user.person.equipment_reservations.new
    @reservation.staff = true if @current_user.admin?
  end
  
  # Create the new reservation record once policies have been agreed to; redirect to #project if successful
  def create
    @reservation = @current_user.person.equipment_reservations.new(params[:equipment_reservation])
    @reservation.staff = true if @current_user.admin?
    
    if @reservation.save
      redirect_to :action => "project", :id => @reservation
    else
      render :action => "new"
    end
  end
  
  # Update project details (project_description and unit_id)
  def project
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    check_if_already_submitted
    
    if request.put?
      @reservation.require_project_validations = true
      if @reservation.update_attributes(params[:equipment_reservation])
        redirect_to :action => "equipment", :id => @reservation
      end
    end 
  end
  
  # The guts of the reservation: dates and equipment
  def equipment
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    check_if_already_submitted
  end

  def update
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    check_if_already_submitted
    @reservation.require_project_validations = true
    @reservation.require_equipment_validations = true
    @reservation.update_attributes(params[:reservation])
    
    if params[:equipment_id]
      @success = @reservation.add_or_remove!(params[:equipment_id])
    else
      @success = true
    end
    @reservation.remove_disallowed_items!

    respond_to do |format|
      format.html { redirect_to :action => "equipment", :id => @reservation }
      format.js
    end
  end
  
  # Returns some info about a particular item
  def about
    @equipment = Equipment.find params[:id]
    render :layout => "popup"
  end
  
  # Finalize the reservation and send it off for approval
  def finalize
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    check_if_already_submitted
    @reservation.require_project_validations = true
    @reservation.require_equipment_validations = true
    if @reservation.valid? && !@reservation.submitted? && @reservation.submit!
      flash[:notice] = "Thank you for submitting your reservation."
      redirect_to :action => "summary", :id => @reservation
    else
      flash[:error] = "There was an error processing your reservation. Please try again."
      redirect_to :action => "equipment", :id => @reservation
    end
  end
  
  # Provide a summary of the reservation.
  def summary
    @reservation = @current_user.person.equipment_reservations.find(params[:id])
    @equipment_reservation = @reservation
  end

  def restricted
    
  end
  
  def students_only
    
  end
  
  def policies
    render :template => "admin/equipment_reservations/policies", :layout => 'popup'
  end
  
  private
  
  def apply_alternate_stylesheet
    @alternate_stylesheet = "student_tech_fee"
  end
  
  def check_if_already_submitted
    if @reservation.submitted?
      # flash[:error] = "This reservation is already submitted, so you cannot change the details of it."
      return redirect_to :action => "summary", :id => @reservation
    end
  end
  
  def check_must_be_student_restriction
    not_equipment_approver = @current_user.roles.select{|u| u.role == Role.find_by_name("equipment_reservation_approver")}.blank?
    if !@current_user.person.is_a?(Student) && (@current_user.admin? && not_equipment_approver)
      return render :action => "students_only"
    end
  end
  
  def check_reservation_restrictions
    if !@current_user.person.valid_equipment_reservation_override? && !@current_user.admin?
      return render :action => 'restricted' if @current_user.person.equipment_reservation_restriction?
      return render :action => 'restricted' if @current_user.person.current_credits.zero?
    end
  end
  
end