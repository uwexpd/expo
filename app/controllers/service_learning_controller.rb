=begin
  Controls the student service learning registration process.
=end
class ServiceLearningController < ApplicationController
  skip_before_filter :login_required
  before_filter :student_login_required
  before_filter :fetch_quarter
  skip_before_filter :student_login_required, :only => [:test]
  skip_before_filter :check_if_student, :only => [:test]
  before_filter :fetch_student_test, :only => [:test]
  before_filter :check_if_student, :fetch_student, :except => [:test]
  before_filter :fetch_enrolled_service_learning_courses
  before_filter :check_enrolled_service_learning_courses, :except => [:select_non_enrolled_course]
  before_filter :assign_service_learning_course, :except => [:which, :complete]
  before_filter :show_minor_warning, :only => [:index, :position]
  before_filter :require_waiver_if_minor, :only => [:choose, :contact, :risk]
  before_filter :check_if_already_registered, :except => [:complete, :my_position, :which, :test]
  before_filter :fetch_position, :only => [:position, :choose, :contact, :risk]
  before_filter :check_if_registration_finalized, :only => [:position, :choose, :contact, :risk, :change]
  before_filter :check_if_registration_open, :only => [:choose, :contact, :risk, :change]


  def index
  end

  def positions
  end

  def position
    @timecodes = @position.times.collect(&:timecodes).flatten
  end

  def which
    if params[:course]
      session[:course] = params[:course]
      redirect_to :action => "index"
    end
  end
  
  def select_non_enrolled_course
    if params[:course]
      session[:non_enrolled_course] = params[:course]
      redirect_to :action => "index"
    end
  end

  def my_position
    @placements ||= @student.service_learning_placements.for(@quarter)
    redirect_to :action => "index" if @placements.empty?
  end

  def change
    @old_placement = @placements.first
    @old_position = @old_placement.position
    @new_position = ServiceLearningPosition.find params[:id]
    if @new_position.filled_for?(@service_learning_course)
      flash[:error] = "We're sorry, but the new position you selected is no longer available. Please choose another."
      redirect_to :action => "index"
    end
    
    if request.put?
      @old_placement.update_attribute(:person_id, nil)
      # TODO: change place_into to the place_into(position, course, unit) format when the student side it set up to use units
      @student.place_into(@new_position, @service_learning_course)
      flash[:notice] = "You are now registered into your new service-learning position."
      redirect_to :action => "complete"
    end
  end

  def choose
    redirect_to :action => "contact", :id => @position
  end

  def contact
    if request.put?
      if params[:student][:phone].blank?
        @student.errors.add :phone, "cannot be blank."
      else
        @student.update_attribute :phone, params[:student][:phone]
        flash[:notice] = "Contact information saved. Thank you."
        redirect_to :action => "risk", :id => @position
      end
    end
  end

  def risk
    if request.put?
      if params[:student][:electronic_signature].blank?
        @student.errors.add :electronic_signature, "cannot be blank."
      else
        @student.update_attribute :service_learning_risk_signature, params[:student][:electronic_signature]
        @student.update_attribute :service_learning_risk_date, Time.now
        # TODO: change place_into to the place_into(position, course, unit) format when the student side it set up to use units
        @student.place_into(@position, @service_learning_course)
        flash[:notice] = "Service-learning registration complete."
        redirect_to :action => "complete"
      end
    end
  end

  def complete
    @placements ||= @student.service_learning_placements.for(@quarter, nil) # by specifying nil here, we get placements from all units except pipeline
    if !@placements.empty? && @placements.first.position.unit.abbreviation == 'bothell'
      return render :template => 'service_learning/complete_bothell'
    end
  end

  def test
    @service_learning_course.finalized = true
    a = rand(2)
    if a == 0
      render :action => 'index'
    elsif a == 1
      positions = @service_learning_course.positions.reject{|p| p.self_placement? || !p.approved?}
      @position = positions[rand(positions.size-1)]
      return render(:text => "couldn't find a position") unless @position
      @timecodes = @position.times.collect(&:timecodes).flatten
      render :action => 'position'
    end
    flash[:notice] = "Time: #{Time.now - @start_time} seconds"
  end

  protected

  def fetch_quarter
    @start_time = Time.now
    @quarter = params[:quarter_abbrev]=='current' ? Quarter.current_quarter : Quarter.find_by_abbrev(params[:quarter_abbrev])
  end
  
  def check_if_student
    unless @current_user.person.is_a? Student
      raise ServiceLearningException.new("You aren't a student.", "In order to register for a service-learning opportunity, you must
                                                                      be a registered student at the University of Washington.")
    end
  end
  
  def fetch_student
    @student = @current_user.person
  end
  
  def fetch_student_test
    unless params[:t] == "U3YxOEAGEMg4a4zD"
      render :text => "400 Bad Request", :status => 400
      return
    end
      
    enrollees = @quarter.service_learning_courses[rand(@quarter.service_learning_courses.count-1)].enrollees
    enrollees = @quarter.service_learning_courses[rand(@quarter.service_learning_courses.count-1)].enrollees if enrollees.empty?
    @student = enrollees[rand(enrollees.size-1)]
    i=0
    while i < 10 && !@student
      @student = enrollees[rand(enrollees.size-1)]
    end
    return render(:text => "couldn't find a student") unless @student
    @placements ||= @student.service_learning_placements.for(@quarter)
    return render(:text => "couldn't find a placements") unless @placements
    @quarter = Quarter.find_by_abbrev("WIN2011")
  end
  
  def fetch_enrolled_service_learning_courses
    if session[:enrolled_service_learning_course_ids]
      @enrolled_service_learning_courses = ServiceLearningCourse.find(session[:enrolled_service_learning_course_ids])
    else
      @enrolled_service_learning_courses = @student.enrolled_service_learning_courses(@quarter) #, nil) # by setting nil here, we check ALL courses except pipeline -- I changed this to not pass nil so that it will default to Carlson instead [mharris2 1/4/11]
      
      # if we don't find any Carlson classes, check Bothell too
      if @enrolled_service_learning_courses.empty?
        @enrolled_service_learning_courses = @student.enrolled_service_learning_courses(@quarter, Unit.find_by_abbreviation("bothell"))
      end
      
      session[:enrolled_service_learning_course_ids] = @enrolled_service_learning_courses.collect(&:id)
    end
  end
  
  def check_enrolled_service_learning_courses
    if @enrolled_service_learning_courses.empty?
      raise ServiceLearningException.new("You don't appear to be enrolled in any service-learning courses.", 
            "Often, this is because you recently added a class and the change has not yet appeared in our system.
             If you think this is an error, please contact the Carlson Center staff at serve@u.washington.edu immediately." )
      # if session[:non_enrolled_course].nil?
      #   redirect_to :action => "select_non_enrolled_course" and return
      # else
      #   @enrolled_service_learning_courses = [ServiceLearningCourse.find(session[:non_enrolled_course])]
      # end
    end
  end
  
  def assign_service_learning_course
    if @enrolled_service_learning_courses.size > 1
      redirect_to :action => "which" and return if session[:course].nil?
      @service_learning_course = @enrolled_service_learning_courses.find{|c| c.id==session[:course].to_i}
    else
      @service_learning_course = @enrolled_service_learning_courses.first
    end    
  end

  def show_minor_warning
    if @student.sdb.age < 18 && !@student.valid_service_learning_waiver_on_file?
      flash[:error] = "Since you are under 18, your parent or guardian <strong>must</strong> sign an Acknowledgement of Risk
                        form on your behalf <strong>before</strong> you can register for a service learning position. Please
                        visit the Carlson Center office in 120 Mary Gates Hall as soon as possible."
    end
  end

  def require_waiver_if_minor
    if @student.sdb.age < 18 && !@student.valid_service_learning_waiver_on_file?
      raise ServiceLearningException.new("You must have an Acknowledgement of Risk on file.",
            "Since you are under 18, your parent or guardian <strong>must</strong> sign an Acknowledgement of Risk
            form on your behalf <strong>before</strong> you can register for a service learning position. Please
            visit the Carlson Center office in 120 Mary Gates Hall as soon as possible.")
    end
  end

  def fetch_position
    @position = ServiceLearningPosition.find(params[:id], :include => :times)
    if @position.filled_for?(@service_learning_course)
      flash[:error] = "We're sorry, but the position you selected is no longer available. Please choose another."
      redirect_to :action => "index"
    end
  end

  def check_if_already_registered
    @placements ||= @student.service_learning_placements.for(@quarter)
    @current_position = @placements.first.position unless @placements.empty?
    redirect_to :action => "complete" if !@service_learning_course.open? && !@placements.empty?
  end
  
  def check_if_registration_finalized
    redirect_to :action => "index" unless @service_learning_course.finalized?
  end
  
  def check_if_registration_open
    unless @service_learning_course.open?
      raise ServiceLearningException.new("Service-learning registration is closed.")
    end
  end

end
