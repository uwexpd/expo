class PipelineController < ApplicationController
  skip_before_filter :login_required
  before_filter :student_login_required, :except => [:stop_email, :download_background_check]
  before_filter :check_if_student, :fetch_student, :except => [:stop_email, :download_background_check]
  
  before_filter :initialize_breadcrumbs

  before_filter :fetch_unit #, :only => [:update_placement_quarter, :index, :confirm_position] -- I changed this to always happen because I don't know why we wouldn't *always* want to define the unit as Pipeline. [mharris2 1/4/11]
  before_filter :fetch_quarter, :except => [:checkin, :email_remove_confirmation, :find_bus_routes, :download_background_check]
  before_filter :fetch_enrolled_courses, :only => [:index, :fetch_course_info, :which]
  before_filter :fetch_course_info, :only => [:index, :show, :search, :favorites, :confirm_position, :remove_position_confirmation,
                                              :orientation_signup, :orientation_rsvp, :pipeline_student_info]
  
  before_filter :fetch_favorite_ids, :except => [:stop_email, :email_remove_confirmation, :find_bus_routes, 
                                                 :update_placement_quarter, :download_background_check]
  before_filter :fetch_rsvp, :only => [:index, :favorites, :orientation_rsvp]
  
  before_filter :fetch_field_info, :only => [:index]
  
  before_filter :fetch_confirmed_positions, :only => [:index, :show, :search, :favorites]
  before_filter :get_progress_statuses, :only => [:index, :favorites]

  layout 'admin'


  helper_method :get_breadcrumbs
  def get_breadcrumbs
    breadcrumbs
  end

  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXPO Home", root_url, {:class => "home"}
    session[:breadcrumbs].add "Pipeline Project", pipeline_base_url
  end

  
  # This will load a page with the search box and some information about the students current status with pipeline
  # If the course does not use the search though it will just load the positions and the sutdents status
  def index
    if @service_learning_course && @service_learning_course.no_filters
      @pipeline_positions = @service_learning_course.positions.uniq
    end
    @show_quarter_select_dropdown = true

    @favorite_positions = ServiceLearningPosition.find(@pipeline_favorites, 
                                                       :include => {:organization_quarter => :organization}, 
                                                       :order => 'organizations.name')
    
    session[:breadcrumbs].add "Home"
  end
  
  def which
    if params[:course]
      course_abbrev = @enrolled_courses.find{|c| c.id==params[:course].to_i}.courses.first.abbrev
      redirect_to :action => "index", :quarter_abbrev => @quarter.abbrev, :course_abbrev => course_abbrev
    end
  end
  
  def show
    @pipeline_position = ServiceLearningPosition.find(params[:id])
    @pipeline_position_id = params[:id]
    @course_abbrev = params[:course_abbrev]
    
    @in_sidebar = true

    @available_slots = nil
    @slots_for_class = nil
    if @pipeline_position.use_slots == true || @service_learning_course.try(:no_filters)
      @available_slots = @service_learning_course.nil? ? @pipeline_position.placements.open_volunteer.size : @pipeline_position.placements.open_for(@service_learning_course).size
      @slots_for_class = @service_learning_course.nil? ? @pipeline_position.number_of_slots_unallocated : @pipeline_position.placements.for(@service_learning_course).size
    end

    
    session[:breadcrumbs].add "#{@pipeline_position.title(false,false,false)} at #{@pipeline_position.organization.name}",
                              :action => 'show', :id => @pipeline_position
  end
  
  def favorites
    @favorite_page = true
    
    @pipeline_positions = ServiceLearningPosition.find(@pipeline_favorites, 
                                                       :include => {:organization_quarter => :organization}, 
                                                       :order => 'organizations.name')
    session[:breadcrumbs].add "Favorites"
  end
  
  def add_favorite
    unless params[:course_abbrev] == "volunteer"
      @course_link = ServiceLearningCourseCourse.find_by_abbrev_and_quarter(params[:course_abbrev], @quarter, @unit)
      @service_learning_course = @course_link.service_learning_course
    end
    
    @in_sidebar = params[:in_sidebar]
    @course_abbrev = params[:course_abbrev]
    
    @pipeline_favorite = PipelinePositionsFavorite.create(:person_id=>@student.id,
                                                          :pipeline_position_id=>params[:id],
                                                          :service_learning_course_id=>(@service_learning_course.id rescue nil))
    
    @pipeline_position_id = @pipeline_favorite.pipeline_position_id
    fetch_favorite_ids
    respond_to do |format|
	    format.js
    end
  end
  
  def remove_favorite
    unless params[:course_abbrev] == "volunteer"
      @course_link = ServiceLearningCourseCourse.find_by_abbrev_and_quarter(params[:course_abbrev], @quarter, @unit)
      @service_learning_course = @course_link.service_learning_course
    end
    
    @favorite_page = params[:favorite_page]
    @in_sidebar = params[:in_sidebar]
    @course_abbrev = params[:course_abbrev]
    
    @pipeline_favorite = PipelinePositionsFavorite.find(:first,:conditions=>{
                                                               :person_id=>@student.id,
                                                               :pipeline_position_id=>params[:id],
                                                               :service_learning_course_id=>(@service_learning_course.id rescue nil)})
    
    @pipeline_position_id = @pipeline_favorite.pipeline_position_id
    
    @pipeline_favorite.delete
    fetch_favorite_ids
    respond_to do |format|
	    format.js
    end
  end
  
  # This runs the student side search, the search method is in the application controller
  # since it is used on both the admin and student side
  # FIXME change this!
  def search
    session[:breadcrumbs].add "Find a Position"

    params[:search] = "course_override" if !params[:search] && @service_learning_course

    if params["search"]
      @results = generate_pipeline_search
      @pipeline_positions = ServiceLearningPosition.find(:all, :include=>[{:organization_quarter=>{:organization=>:locations}},
                                                         :pipeline_positions_subjects,:pipeline_positions_grade_levels,
                                                         :pipeline_positions_tutoring_types, :times], 
                                                         :conditions=>{:id=>@results.collect{|r|r.id}},
                                                         :order => "organizations.name")
    end

    respond_to do |format|
      format.html {
        fetch_rsvp
        get_progress_statuses
        fetch_field_info
      }
	    format.js {
	    }
    end
  end
  
  # Uses the Trip Planner model to find bus routes to the school from Terry/Lander
  def find_bus_routes
    @start_date = DateTime.civil(params[:route][:"trip_day(1i)"].to_i,
                                 params[:route][:"trip_day(2i)"].to_i,
                                 params[:route][:"trip_day(3i)"].to_i,
                                 params[:route][:"trip_time(4i)"].to_i,
                                 params[:route][:"trip_time(5i)"].to_i)
    
    @routes = TripPlanner.find_routes({'Dest'=>params[:"dest"], 'Arr'=>params[:route][:"arr"]}, @start_date)
    
    respond_to do |format|
	    format.js
    end
  end
  
  # This page is the orientation survey page
  def orientation_signup
    @pipeline_student_info = @student.pipeline_student_info
    if @pipeline_student_info.nil?
      @pipeline_student_info = PipelineStudentInfo.new(:person => @student)
    end
    session[:breadcrumbs].add "Orientation Signup"
  end
  
  # Link to the background check pdf download
  # This is available without logging in
  def download_background_check
    send_file 'files/background_check.pdf', :type=>"application/pdf"
  end
  
  # Saves the survey info that the student inputs
  def pipeline_student_info
    @student.phone = params[:phone]
    @student.save
    
    @pipeline_student_info = @student.pipeline_student_info
    if @pipeline_student_info.nil?
      @pipeline_student_info = PipelineStudentInfo.new(params[:pipeline_student_info].merge({:require_validations => true}))
      respond_type = @pipeline_student_info.save
    else
      respond_type = @pipeline_student_info.update_attributes(params[:pipeline_student_info].merge({:require_validations => true}))
    end
    
    respond_to do |format|
      if respond_type
        flash[:notice] = 'Your survey info was successfully saved.'
        format.html { redirect_to :controller => 'pipeline', :action => 'orientation_rsvp',
                                  :quarter_abbrev => @quarter.abbrev, :course_abbrev => @course_abbrev }
      else
        format.html { render :action => "orientation_signup", :quarter_abbrev => @quarter.abbrev, :course_abbrev => @course_abbrev }
      end
    end
    
    session[:breadcrumbs].add "Student Info"
  end
  
  # This page list the upcoming orientations and the one that they are currently RSVPed for
  def orientation_rsvp
    session[:breadcrumbs].add "Orientation Times"
  end
  
  # Allows the student to confirm a position
  #   If the position requires slots or if the course does not use the filters there will 
  #   have to be avalible slots for the student to sign up
  # If the quarter the student is browsing is not the current one then they can not confirm a position
  def confirm_position
    @error_message = nil
    if @quarter == @current_quarter
      @pipeline_position = ServiceLearningPosition.find(params[:id])
    
      service_learning_placement = ServiceLearningPlacement.find_by_person_id_and_service_learning_position_id(@student.id, params[:id])
      if service_learning_placement.nil?
        force_placement = !(@pipeline_position.use_slots? || (!@service_learning_course.nil? && @service_learning_course.no_filters?))
        if !@student.place_into!(@pipeline_position, @service_learning_course, @unit, false, "2", force_placement)
          @error_message = "Sorry, we couldn't place you into that position."
        end
      else
        @error_message = "You already have signed up for this position."
      end
    else
      @error_message = "You can only confirm positions for #{@current_quarter.title}."
    end
    
    fetch_confirmed_positions    
    
    respond_to do |format|
      format.html { redirect_to :action => "show", :id => @pipeline_position }
	    format.js
    end
    session[:breadcrumbs].add "Confirm Position"
  end
  
  
  # Removes the confirmation and deletes the slot if needed
  # Wont allow positions to be removed if it is not the current quarter
  def remove_position_confirmation
    if @quarter == @current_quarter
      pipeline_placement = ServiceLearningPlacement.find(params[:id])
    
      @pipeline_position = pipeline_placement.position
    
      if @pipeline_position.use_slots || (!@service_learning_course.nil? && @service_learning_course.no_filters)
        pipeline_placement.person_id = nil
        pipeline_placement.save
      else
        pipeline_placement.destroy
      end
    else
      @error_message = "You can only remove positions for #{@current_quarter.title}."
    end
    
    @pipeline_position.reload
    fetch_confirmed_positions
    
    respond_to do |format|
      format.html { redirect_to({:action => params[:action_from]} || {:action => "show", :id => @pipeline_position }) }
	    format.js
    end
  end
  
  # If the student clicks on the stop bugging link in pipeline email they will be sent here and set to inactive
  def stop_email
    student = Token.find_object(params[:student_id], params[:token], false)
    unless student.nil?
      student.pipeline_inactive = true
      student.save
    else
      @error = true
    end 
    session[:breadcrumbs].add "Stop E-mail Request"
  end
  
  # This might not be used anymore
  # This will remove the placement for the student based on their id and the placements id
  def email_remove_confirmation
    pipeline_placement = ServiceLearningPlacement.find(:first, 
                                                :conditions => {:person_id => @student.id, 
                                                                :id => params[:id]})
    unless pipeline_placement.nil?
      pipeline_placement.destroy
    else
      @error = true
    end
  end
  
  # This is used to migrate a position over to the CURRENT QUARTER
  # If needed the organization will be actived and the position will be created, but not be approved
  def update_placement_quarter
    @pipeline_placement = ServiceLearningPlacement.find_by_person_id_and_id(@student.id, params[:id])
    
    unless @pipeline_placement.nil?
      quarter_to = Quarter.current_quarter
      if quarter_to == @pipeline_placement.position.quarter
        @error = "The placement quarter and the migration quarter are the same."
      else
        if params[:migrate]
          # look to see if the position has been migrated before
          @new_position = ServiceLearningPosition.find_by_previous_service_learning_position_id(@pipeline_placement.position.id)
          if @new_position.nil?
            pipeline_position = @pipeline_placement.position
            organization_quarter = OrganizationQuarter.find(:first, 
                                                            :conditions => {:organization_id => pipeline_position.organization.id,
                                                                            :quarter_id => quarter_to.id,
                                                                            :unit_id => @unit.id})
            if organization_quarter.nil?
              organization_quarter = OrganizationQuarter.create(:organization_id => pipeline_position.organization.id,
                                                                :quarter_id => quarter_to.id,
                                                                :unit_id => @unit.id )
            end
          
            @new_position = pipeline_position.clone(['details','times','supervisor','location','pipeline_position'])
            @new_position.update_attribute(:organization_quarter_id, organization_quarter.id)
            @new_position.save
          end
        
          new_pipeline_placement = ServiceLearningPlacement.find_by_person_id_and_service_learning_position_id(@student.id,@new_position.id)
        
          if new_pipeline_placement.nil?
            new_pipeline_placement = ServiceLearningPlacement.new
            new_pipeline_placement.service_learning_position_id = @new_position.id
            new_pipeline_placement.person = @student
            new_pipeline_placement.save
          else
            @error = "It looks like your position was already moved. If you think this is an error contact Pipeline."
          end
        end
      end
    else
      @error = "The link did not work!"
    end
  end
  
  protected
  
  def fetch_quarter
    @current_quarter = Quarter.current_quarter
    if params[:quarter_abbrev].nil?
      @quarter = @current_quarter
    else
      @quarter = (params[:quarter_abbrev]=='current') ? @current_quarter : Quarter.find_by_abbrev(params[:quarter_abbrev])
    end
    session[:breadcrumbs].add "#{@quarter.title}", pipeline_quarter_path(@quarter), :class => 'quarter_select'
  end
  
  def check_if_student
    unless @current_user.person.is_a? Student
      raise ServiceLearningException.new("You aren't a student.", "In order to search and view pipeline positions, you must
                                                                      be a registered student at the University of Washington.")
    end
  end
  
  def fetch_student
    @student = @current_user.person
    @student.update_attribute('pipeline_inactive', false) if @student.pipeline_inactive
  end
    
  def fetch_favorite_ids
    # unless params[:course_abbrev] == "volunteer"
    #       @course_link = ServiceLearningCourseCourse.find_by_abbrev_and_quarter(params[:course_abbrev], @quarter)
    #       @service_learning_course = @course_link.service_learning_course
    #     end
    
    @pipeline_favorites = @student.pipeline_favorites.find(:all, 
                              :include => [:organization_quarter],
                              :conditions => {"organization_quarters.quarter_id" => @quarter.id,
                                              "pipeline_positions_favorites.service_learning_course_id" => (@service_learning_course.id rescue nil)},
                              :select => "id").map(&:id)
  end
  
  def fetch_field_info
    @subjects = PipelinePositionsSubject.find(:all,:order=>"name")
    @grades = PipelinePositionsGradeLevel.all
    @formats = PipelinePositionsTutoringType.find(:all,:order=>"name")
    
    @schools = School.find(:all,:order => "organizations.name")
    
    @neighborhoods = @schools.collect{|school| school.locations[0].neighborhood rescue nil}.compact.uniq.sort
  end
  
  def fetch_enrolled_courses
    @enrolled_courses = @quarter.service_learning_courses.for_unit(@unit).collect{|c| c if c.enrolls?(@student)}.compact
  end
  
  # This finds the course that should be used, either a real course or the volunteer course
  # This is also used to redirect the student to the proper web address
  def fetch_course_info
    if params[:course_abbrev].nil?
            
      enrolled_course_abbrev = "volunteer"
      unless @enrolled_courses.empty? || @enrolled_courses.first.courses.empty?        
        enrolled_course_abbrev = @enrolled_courses.first.courses.first.abbrev
      end
      
      if enrolled_course_abbrev == "volunteer"
        # flash[:notice] = "You have been redirected to the volunteer search."
      else
        # flash[:notice] = "You have been redirected to #{enrolled_course_abbrev}'s search page."
      end
      return redirect_to :action => "index", :quarter_abbrev => @quarter.abbrev, :course_abbrev => enrolled_course_abbrev
    elsif params[:course_abbrev] != "volunteer"
      @course_link = ServiceLearningCourseCourse.find_by_abbrev_and_quarter(params[:course_abbrev], @quarter, @unit)
      if @course_link.nil?
        flash[:error] = "The course was not found. You have been redirected to the volunteer search."
        return redirect_to :action => "index", :quarter_abbrev => @quarter.abbrev, :course_abbrev => "volunteer"
      end
      
      @service_learning_course = @course_link.service_learning_course
      @pipeline_course_filter = @service_learning_course.pipeline_course_filter
      @filters = @pipeline_course_filter.try(:filters)
      
      unless @service_learning_course.enrolls?(@student)
        flash[:error] = "You are not enrolled in #{@service_learning_course.title}. You have been redirected to the volunteer search."
        return redirect_to :action => "index", :quarter_abbrev => @quarter.abbrev, :course_abbrev => "volunteer"
      end
    end
    @filters = {} if @filters.nil?
    
    @course_abbrev = params[:course_abbrev]
  end
  
  def fetch_confirmed_positions
    @confirmed_positions = @student.pipeline_placements.for(@quarter)
    @course_positions = @confirmed_positions.collect{|cp| cp if cp.service_learning_course_id == (@service_learning_course.id rescue nil)}.compact
  end
  
  def fetch_rsvp
    @student_rsvp = nil
    # don't bother looking for a rsvp if they are valid
    unless @student.show_pipeline_position_contact?
                                
      @rsvp_event_times = EventTime.find(:all, :include => [{:event => [:event_type, :unit]}], 
                                         :conditions => {:events => {:event_types => {:title => "Orientation"},
                                                                     :units => {:abbreviation => "pipeline"}},
                                                         :start_time => Time.now..(Time.now+1.year)},
                                         :order => "event_times.start_time ASC")
                                        
      events = @rsvp_event_times.collect{|et| et.event}.uniq
    
      if @student.show_pipeline_position_contact? == false
        for event in events
          @student_rsvp = event.find_attendee(@student)
          break unless @student_rsvp.nil?
        end
      end
      
      @rsvp_event_times = (@rsvp_event_times << @student_rsvp.event_time).uniq unless @student_rsvp.nil?
      
    end
  end
  
  def fetch_unit
    @unit = Unit.find_by_abbreviation "pipeline"
  end
  
  # Gets the students statues on various things that need to be done before the student can confirm a position
  def get_progress_statuses
    @progress_statuses = {}
    
    unless @student.pipeline_orientation_valid?
      unless @rsvp_event_times.empty?
        if @student_rsvp.nil?
          @progress_statuses[:orientation] = {
            :text => "You have not attended an orientation. Before you can participate as a volunteer for the Pipeline Project,
                      you must RSVP for and attend an orientation.",
            :css_class => "action required",
            :button => :signup
          }
        elsif @student_rsvp.checkin_time.nil?
          @progress_statuses[:orientation] = {
            :text => "You're scheduled to attend an orientation on #{@student_rsvp.event_time.start_time.to_s(:date_at_time12)}.
                      Please arrive on time, as late attendees will be asked to attend another orientation.  Also, please bring 
                      a photo ID (driver's license or Husky Card) to the orientation, as a Washington State Patrol Background 
                      Check will be completed for all prospective tutors.",
            :css_class => "in progress",
            :button => :change
          }
        end
      else
        @progress_statuses[:orientation] = {
          :text => "You need to attend an orientation, but there are no orientations at this time.",
          :css_class => "action required", 
          :button => false
        }
      end
    else
      @progress_statuses[:orientation] = {
        :text => "You attended an orientation on #{@student.pipeline_orientation.to_s(:date_with_day_of_week) rescue nil }.",
        :css_class => "success",
        :button => false
      }
    end

    if @student.show_pipeline_position_contact?
      @progress_statuses[:background_check] = {
        :text => "Background check cleared on #{@student.pipeline_background_check.to_s(:date_with_day_of_week) rescue nil}.",
        :css_class => "success",
        :button => false
      }
    elsif @student.pipeline_orientation_valid?
      @progress_statuses[:background_check] = {
        :text => "Your background check is pending. As soon as it is complete, you'll be able to participate fully as a
                  Pipeline Project tutor.",
        :css_class => "in progress",
        :button => false
      }
    else
      @progress_statuses[:background_check] = {
        :text => "Please <strong>print</strong> your background check form and bring the completed form to your orientation.",
        :css_class => "action required",
        :button => true
      }
    end

    if @service_learning_course.nil?
      @progress_statuses[:search] = {
        :text => "Searching is open for volunteers. You should identify your top three favorite schools that 
                  work with your schedule and interests.",
        :css_class => "success",
        :button => true
      }
    else
      if @service_learning_course.finalized
        @progress_statuses[:search] = {
          :text => "Searching is open for #{@service_learning_course.title}. You should identify your top three
                    favorite schools that work with your schedule and interests.",
          :css_class => "success",
          :button => true
        }
      else
        @progress_statuses[:search] = {
          :text => "Searching is not open for #{@service_learning_course.title}.",
          :css_class => "light",
          :button => false
        }
      end
    end

    if @quarter != @current_quarter
      @progress_statuses[:position] = {
        :text => "You can not confirm positions for #{@quarter.title}.",
        :css_class => "light"
      }
    elsif !@student.show_pipeline_position_contact?
      @progress_statuses[:position] = {
        :text => "You have not yet completed the steps above.",
        :css_class => "light"
      }
    elsif !@service_learning_course.nil? && @service_learning_course.registration_open_time.nil?
      @progress_statuses[:position] = {
        :text => "Your course is not allowing confirmations at this time.",
        :css_class => "light"
      }
    elsif !@confirmed_positions.empty?
      @progress_statuses[:position] = {
        :text => "You are currently confirmed in the following positions:",
        :css_class => "success"
      }
    else
      @progress_statuses[:position] = {
        :text => "Please confirm the final position that you selected and are currently volunteering at.",
        :css_class => "action required"
      }
    end

  end
  
end