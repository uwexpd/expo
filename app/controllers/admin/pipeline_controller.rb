class Admin::PipelineController < Admin::BaseController
  before_filter :fetch_unit
  before_filter :pipeline_breadcrumbs
  before_filter :fetch_quarter
  before_filter :use_pipeline_links
  
  # Grabs the upcoming orientations and the quarter stats
  def index
    session[:breadcrumbs].add "Home"
    @orientation_times = EventTime.find(:all, :include => [{:event => [:event_type, :unit]}], 
                                        :conditions => {:events => {:event_types => {:title => "Orientation"},
                                                                    :units => {:abbreviation => "pipeline"}},
                                                        :start_time => (Time.now)..(Time.now+1.month)},
                                        :order => "event_times.start_time DESC",
                                        :limit => 5)
    
    # stats                    
    @pipeline_placements = ServiceLearningPlacement.find(:all, 
                                        :include => [{:position => [:organization_quarter]}],
                                        :conditions => ["service_learning_placements.person_id IS NOT NULL AND
                                                         service_learning_placements.service_learning_course_id IS NOT NULL AND
                                                         service_learning_positions.unit_id = :unit_id AND
                                                         organization_quarters.quarter_id = :quarter_id",
                                                         {:unit_id => @unit.id, :quarter_id => @quarter.id}])
    
    @inner_pipeline_placements_size = @pipeline_placements.select{|p| p.course.pipeline_student_type_name == "Inner Pipeline"}.count
    @service_learning_placements_size = @pipeline_placements.select{|p| p.course.pipeline_student_type_name == "Service Learning"}.count
    
    @other_pipeline_placements_size = @pipeline_placements.select{|p| p.course.pipeline_student_type_id.blank? }.count
                                                         
    @volunteer_placements_size = ServiceLearningPlacement.find(:all, 
                                   :include => [{:position => [:organization_quarter]}],
                                   :conditions => ["service_learning_placements.person_id IS NOT NULL AND
                                                    service_learning_placements.service_learning_course_id IS NULL AND
                                                    service_learning_positions.unit_id = :unit_id AND
                                                     organization_quarters.quarter_id = :quarter_id",
                                                    {:unit_id => @unit.id, :quarter_id => @quarter.id}]).count
                                                    
    @quarter_placements_size = @inner_pipeline_placements_size + @service_learning_placements_size + @other_pipeline_placements_size + @volunteer_placements_size
    
    @active_students_size = Student.count(:all, :conditions => ["pipeline_background_check >= ?", (Time.now-2.year)])
    @all_students_size = Student.count(:all, :conditions => ["pipeline_background_check IS NOT NULL"])
    
    @show_quarter_select_dropdown = true
    
    respond_to do |format|
      format.html
    end
  end
  
  # Lists all of the Pipeline Orientations
  # A Event is considered a Pipeline Orientation if it has the event_type Orientaion and the unit is Pipeline
  def orientation_management
    session[:breadcrumbs].add "Orientation Management"
    
    @orientations = Event.find(:all, :include => [ :event_type, :unit, :times ], 
                               :conditions => {:event_types => {:title => "Orientation"},
                                               :units => {:abbreviation => "pipeline"}, 
                                               :created_at => (Time.now - 1.years)..Time.now },
                               :order => "event_times.start_time DESC")
                               
    @show_quarter_select_dropdown = true
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  # From the Oriantation page you can select mutiple event times and view all of the participants
  # This list also grabs the course that the student is associated with
  # TODO line-92 should be fixed: can't convert nil into hash [joshlin 12/16/2011]
  def orientation_participants
    session[:breadcrumbs].add "Selected Orentation Participants"
    
    @invitees = []
    if params[:select]
      params[:select].each do |obj_type,objects|
        objects.each do |obj_id,value|
          obj = eval("#{obj_type}.find(#{obj_id})")
          if obj.is_a? EventTime
            @invitees << obj.invitees
          end
        end
      end
    end
    @invitees = @invitees.flatten.compact
    
    @pipeline_courses = ServiceLearningCourse.find_all_by_unit_id_and_quarter_id(@unit, @quarter)
    @pipeline_course_courses_hash = {} # holds the course courses by id
    @pipeline_courses.each{|c| c.courses.each{|cc| @pipeline_course_courses_hash[cc.id] = c}}
    @course_enrollee_hash = {} # holds all of the courses' students
    @pipeline_courses.collect(&:students).each{|s| @course_enrollee_hash = @course_enrollee_hash.merge(s)}
    # use: course_course = @pipeline_course_courses_hash[@course_enrollee_hash[person.id][:course_id]]
    # sees if the person is in the course and pulls up the course course record
    
    params[:f] ||= {}
    
  end
  
  # Lists the participants for a single Event Time
  def participants
    @time = EventTime.find(params[:event_time_id])
    @event = @time.event
    @invitees = @time.invitees
    
    session[:breadcrumbs].add "Orentation Participants"
    
    render :template => "admin/events/times/show"
  end
  
  # clears the students background check, used on the student tab in the student info page
  def clear_background_check
    @student = Person.find(params[:person_id])
    
    @student.pipeline_background_check = Time.now
    
    @pipeline_tab = true if params[:student_tab]
    
    @student.save
    
    respond_to do |format|
      format.js
    end
  end
  
  # The next two methods use the 'students_form' With Selected sidebar
  # date drop down with link to each function under it
  # Clears the passed groups background check
  def group_background_check_clear
    date = Date.parse(params['date_select']['s(1i)']+'-'+params['date_select']['s(2i)']+'-'+params['date_select']['s(3i)'])
    @date_string = date.strftime('%x')
    @student_ids = []
    if params[:select]
      params[:select].each do |obj_type,objects|
        objects.each do |obj_id,value|
          obj = eval("#{obj_type}.find(#{obj_id})")
          if obj.is_a? Student
            obj.pipeline_background_check = date
            obj.save
            @student_ids << obj.id
          elsif (obj.is_a? EventInvitee) || (obj.is_a? ServiceLearningPlacement)
            obj.person.pipeline_background_check = date
            obj.person.save
            @student_ids << obj.person.id
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  # Sets the passed groups orientation time
  def group_orientation_clear
    date = Date.parse(params['date_select']['s(1i)']+'-'+params['date_select']['s(2i)']+'-'+params['date_select']['s(3i)'])
    @date_string = date.strftime('%x')
    @student_ids = []
    if params[:select]
      params[:select].each do |obj_type,objects|
        objects.each do |obj_id,value|
          obj = eval("#{obj_type}.find(#{obj_id})")
          if obj.is_a? Student
            obj.pipeline_orientation = date
            obj.save
            @student_ids << obj.id
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  # Used to toggle a group of students to pipeline_inactive flag
  def group_toggle_active
    @student_ids = []
    @active = (params[:active] == "true") ? true : false
    if params[:select]
      params[:select].each do |obj_type,objects|
        objects.each do |obj_id,value|
          obj = eval("#{obj_type}.find(#{obj_id})")
          if obj.is_a? Student
            obj.pipeline_inactive = !@active
            obj.save
            @student_ids << obj.id
          elsif (obj.is_a? EventInvitee) || (obj.is_a? ServiceLearningPlacement)
            obj.person.pipeline_inactive = !@active
            obj.person.save
            @student_ids << obj.person.id
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  # Sets a students background check to nil, used on the student tab in the student info page
  def unclear_background_check
    @student = Person.find(params[:person_id])
    
    @student.pipeline_background_check = nil
    
    @student.save
    
    respond_to do |format|
      format.js
    end
  end
  
  # Sets a students pipeline orientation check to nil, used on the student tab in the student info page
  def remove_pipeline_orientation
    @student = Person.find(params[:person_id])
    
    @student.pipeline_orientation = nil
    
    @student.save
    
    respond_to do |format|
      format.js
    end
  end
  
  # Grabs the students pipeline survey infomation or creates a new one, used on the student tab in the student info page
  def edit_pipeline_survey
    @student = Person.find(params[:person_id])
    
    @pipeline_student_info = @student.pipeline_student_info
    if @pipeline_student_info.nil?
      @pipeline_student_info = PipelineStudentInfo.new(:person => @student)
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  # Changes the information in a students info survey, used on the student tab in the student info page
  def update_pipeline_survey
    @student = Person.find(params[:person_id])
    
    if @student.pipeline_student_info.nil?
      @student.pipeline_student_info = PipelineStudentInfo.new
    end
    
    @student.pipeline_student_info.update_attributes(params[:pipeline_student_info])
    
    respond_to do |format|
      format.js
    end
  end
  
  # Grabs the students that attended a Orientation and show their survey responses
  # this is accessed from an event time row
  def student_questions
    @time = EventTime.find(params[:event_time_id])
    
    @attendees = @time.invitees.find(:all, :include => [:person], :order => "people.fullname")
    
    session[:breadcrumbs].add "Student Questions"
  end
  
  # Lists the students that are invloved with Pipeline
  # params[:i] is the last name filter
  # params[:f] holds the various filters like:
  #   params[:f][:bc] = background check valid or expired
  #   params[:f][:q] = a quarter filter
  #   params[:f][:ia] = show inactive students
  def students
    search_params = {}
    search_query = []
    base_query = " (people.pipeline_orientation IS NOT NULL OR people.pipeline_background_check IS NOT NULL) "
    
    if params[:i]
      @alpha_filter = params[:i]
      search_query << " people.lastname LIKE :index "
      search_params = search_params.merge({ :index => params[:i]+'%' })
    end
    
    params[:f] ||= {}
    unless params[:f].empty?
      unless params[:f][:bc].nil? || params[:f][:bc].empty?
        if params[:f][:bc] == "valid"
          search_query << " people.pipeline_background_check > :bc "
        elsif params[:f][:bc] == "expired"
          search_query << " people.pipeline_background_check < :bc "
        else
          base_query = " (people.pipeline_orientation IS NOT NULL AND people.pipeline_background_check IS NULL) "
        end
        search_params = search_params.merge({ :bc => Time.now-2.year })
      end
      
      unless params[:f][:q].nil? || params[:f][:q].empty?
        search_quarter = Quarter.find params[:f][:q].to_i
        search_query << " quarters.id = :quarter_id "
        search_params = search_params.merge({ :quarter_id => search_quarter.id })
        
        search_query << " service_learning_positions.unit_id = :unit_id "
        search_params = search_params.merge({ :unit_id => @unit.id })
      end
    end
    
    if params[:f].empty? || params[:f][:ia].nil?
      base_query = " (#{base_query} AND (people.pipeline_inactive IS NULL OR people.pipeline_inactive = 0)) "
    end
    
    search_query << base_query
    final_query = search_query.join(" AND ")
    
    @students = Student.paginate(:all, 
     :include => [{:service_learning_placements => [{:position => [{:organization_quarter => :quarter}, :unit]}, :course]}], 
     :conditions => [final_query,search_params],
     :order => "fullname",
     :page => params[:page])
    
    session[:breadcrumbs].add "Students"
  end
  
  # Shows the current quarter pipeline placements using the placements unit_id and its organization quarter's quarter_id
  def placements
    @pipeline_placements = ServiceLearningPlacement.find(:all, 
                 :include => [{:position => [{:organization_quarter => :organization}, :children]}, :person, :course],
                 :conditions => ["service_learning_placements.person_id IS NOT NULL AND
                                  service_learning_positions.unit_id = :unit_id AND
                                  organization_quarters.quarter_id = :quarter_id",
                                  {:unit_id => @unit.id, :quarter_id => @quarter.id}])
    @limit_with_selected = true
    
    @show_quarter_select_dropdown = true
    
    # make a hash of ids of the migrated positions
    @migrated = {}
    for placement in @pipeline_placements
      for child_position in placement.position.children
        for child_placement in child_position.placements
          if child_placement.person_id == placement.person_id
            @migrated[placement.id] = child_position.quarter.title 
          end
        end
      end
    end
    
    session[:breadcrumbs].add "Placements"
  end
  
  # The next four methods manage the pipeline position attributes
  # The 'Manage Links' sidebar on the pipeline home are where these are used
  def manage_position_attributes
    @attributes = eval("#{params[:attribute_class]}.find(:all, :order=>'name')")
  end
  def create_position_attribute
    @attribute = eval("#{params[:attribute_class]}.create(:name=>#{params[:name]})")
    
    respond_to do |format|
      format.js
    end
  end
  def update_position_attribute
    @attribute = eval("#{params[:attribute_class]}.find(#{params[:id]})")
    @attribute.update_attributes(:name=>params[:name])
    
    respond_to do |format|
      format.js
    end
  end
  def remove_position_attribute
    @attribute = eval("#{params[:attribute_class]}.find(#{params[:id]})")
    @attribute.destroy()
    
    respond_to do |format|
      format.js
    end
  end
  
  def remove_position_confirmation
    
    position = ServiceLearningPlacement.find params[:id]
    position.destroy
    
  end
  
  # Change to use person.place_into!(position, service_learning_course, @unit, false, "2", !@pipeline_position.use_slots)
  def add_position_confirmation
    @student = Student.find params[:person_id]
    @pipeline_position = ServiceLearningPosition.find(params[:position_id])
    
    course_id = nil
    unless params[:course_id].nil?
      unless params[:course_id] == "v"
        course_id = params[:course_id].to_i
      end
    end
    
    pipeline_placement = ServiceLearningPlacement.new
    pipeline_placement.service_learning_position_id = params[:position_id]
    pipeline_placement.person = @student
    pipeline_placement.service_learning_course_id = course_id
    pipeline_placement.unit_id = @unit.id
    
    pipeline_placement.save
    
    respond_to do |format|
	    format.js
    end
  end
  
  protected
  
  def pipeline_breadcrumbs
    session[:breadcrumbs].add @unit.name, admin_pipeline_index_url
  end
  
  def fetch_quarter
    @quarter = params[:quarter_abbrev] ? Quarter.find_by_abbrev(params[:quarter_abbrev]) : Quarter.current_quarter
    session[:breadcrumbs].add "#{@quarter.title}", service_learning_home_path(@unit, @quarter), :class => 'quarter_select'
  end
  
  def fetch_unit
    @unit = Unit.find_by_abbreviation "pipeline"
    require_user_unit @unit
  end
  
  def use_pipeline_links
    @use_pipeline_links = true
  end
end