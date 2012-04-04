class Admin::FrontDeskController < Admin::BaseController
  
  uses_charts
  
  def index
    session[:breadcrumbs].add "Front Desk"
    @appointment = Appointment.new
		@units = Unit.all
  end
  
  def find_student
    if params[:clear] || params[:student_no].blank? && params[:student_system_key].blank?
      @student = nil
    elsif !params[:student_system_key].blank?
      @student = Student.find_by_system_key(params[:student_system_key])
      @source = :system_key
    else
      @student = Student.find_by_student_no(params[:student_no])
      @source = :student_no
    end

    respond_to do |format|
      format.js
    end
  end

  def quick_contact
    @quick_contact = QuickContact.new(params[:quick_contact])
    @quick_contact.contact_type_id = ContactType.find_or_create_by_title(params[:contact_type]).id
    @quick_contact.start_time = 3.minutes.ago
    @quick_contact.end_time = Time.now
    @quick_contact.source = "front_desk"
    @quick_contact.save
    @quick_contact.checkin! if @quick_contact.valid?
    
    respond_to do |format|
      format.js
    end
  end
  
  # def add_fake_appointments
  #   student_nos = [6,7,8,9]
  #   student_nos.each do |student_no|
  #     students = Student.find(:all,:conditions=>["student_no LIKE ?",student_no.to_s+"%"],:limit=>(rand(8)*51*rand(6)))
  #     students.each do |student|
  #       unit_id = rand(7)+1
  #       start_time = (rand(1000000)).minutes.ago
  #       end_time = start_time+rand(3).hour+(rand(3)*15).minutes+15.minutes
  #       check_in_time = start_time+(rand(30)-15).minutes
  #       contact_type = ContactType.find (rand(4)+1)
  #       drop_in = rand(2)
  #       if contact_type.title = "In-person"
  #         drop_in = rand(2)
  #       end
  #       staff_person_id = User.admin[rand(User.admin.size)-1].person_id
  #       
  #       appointment = Appointment.new(:student_id=>student.id,:unit_id=>unit_id,:start_time=>start_time,
  #                                     :end_time=>end_time,:check_in_time=>check_in_time,
  #                                     :contact_type=>contact_type,:drop_in=>drop_in,
  #                                     :staff_person_id=>staff_person_id)
  #       appointment.save!
  #     end
  #   end
  # end
end