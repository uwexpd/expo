class Admin::AppointmentsController < Admin::BaseController

  before_filter :add_appointments_breadcrumbs
  
  def index
    @appointments = Appointment.paginate(:order => "start_time DESC", :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @appointments }
    end
  end
    
  def show
    @appointment = Appointment.find(params[:id])
    @student = @appointment.student
    session[:breadcrumbs].add "#{@appointment.start_time.to_s(:date_time12)} with #{@appointment.student.firstname_first rescue "unknown"}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @appointment }
    end
  end
  
  def new
    @appointment = Appointment.new
    @appointment.student = Student.find(params[:student_id]) if params[:student_id]
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @appointment }
    end
  end
  
  def create
    @my = @current_user.person
    @appointment = Appointment.new(params[:appointment])
    @appointment.start_time = Time.now if @appointment.start_time.blank?
    @student = @appointment.student

    respond_to do |format|
      if @appointment.save
        @appointment.checkin! if params[:check_in_now]
        flash[:notice] = "Successfully created appointment."
        format.html { redirect_to appointment_path(@appointment) }
        format.xml  { render :xml => @appointment, :status => :created, 
                             :location => appointment_path(@appointment) }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @appointment.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end
  
  def edit
    @appointment = Appointment.find(params[:id])
    session[:breadcrumbs].add "#{@appointment.start_time.to_s(:date_time12)} with #{@appointment.student.firstname_first rescue "unknown"}", appointment_path(@appointment)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @appointment = Appointment.find(params[:id])

    respond_to do |format|
      if @appointment.update_attributes(params[:appointment])
        flash[:notice] = "Successfully updated appointment."
        format.html { redirect_to appointment_path(@appointment) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @appointment.errors, :status => :unprocessable_entity }
        format.js   { @errors = true}
      end
    end
  end
  
  def destroy
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
    flash[:notice] = "Successfully destroyed appointment."
    respond_to do |format|
      format.html { redirect_to appointments_url(@appointment) }
      format.xml  { head :ok }
      format.js
    end
  end

  def checkin
    @appointment = Appointment.find(params[:id])
    if @appointment.checkin!
      respond_to do |format|
        format.html { redirect_to appointment_path(@appointment) }
        format.js
      end
    end
  end

  def followup_to
    @appointment = Appointment.find(params[:id])
    @appointment.update_attribute(:previous_appointment_id, params[:previous_appointment_id])
    
    respond_to do |format|
      format.html { redirect_to appointment_path(@appointment) }
      format.js
    end
  end

  protected

  def add_appointments_breadcrumbs
    session[:breadcrumbs].add "Appointments", appointments_path
  end

end
