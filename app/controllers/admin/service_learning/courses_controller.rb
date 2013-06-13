class Admin::ServiceLearning::CoursesController < Admin::ServiceLearningController
  before_filter :courses_breadcrumbs
  before_filter :generate_copy_options, :only => [:index, :show, :change_quarter_option]
  before_filter :get_tutoring_logs, :only => [:evaluation, :submit_evaluation]

  # GET /service_learning_courses
  # GET /service_learning_courses.xml
  def index
    @service_learning_courses = @quarter.service_learning_courses.for_unit(@unit)

    @new_service_learning_course = ServiceLearningCourse.new
    @new_service_learning_course.quarter_id = @quarter.id
    @new_service_learning_course.courses.build
    
    if @use_pipeline_links
      @volunteer_placements_count = ServiceLearningPlacement.find(:all, 
                                     :include => [{:position => :organization_quarter}],
                                     :conditions => ["service_learning_placements.person_id IS NOT NULL AND
                                                      service_learning_placements.service_learning_course_id IS NULL AND
                                                      service_learning_positions.unit_id = :unit_id AND
                                                      organization_quarters.quarter_id = :quarter_id",
                                                      {:unit_id => @unit.id, :quarter_id => @quarter.id}]).count
    end                       
    
    @show_quarter_select_dropdown = true
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_learning_courses }
    end
  end

  # GET /service_learning_courses/1
  # GET /service_learning_courses/1.xml
  def show
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    session[:breadcrumbs].add @service_learning_course.title rescue "Detail"

    if params[:view] == 'syllabus'
      file_path = File.join(RAILS_ROOT, 'files', @service_learning_course.syllabus.original.public_path)
      type = @service_learning_course.syllabus.original.content_type
      disposition = params[:disposition] == 'inline' ? 'inline' : 'attachment'
      return send_file(file_path, :disposition => disposition, :type => (type || "text")) unless file_path.nil?
    end
    
    if params[:filters] == 'true' || (params[:tab] == "position_matches" && @use_pipeline_links)
      @pipeline_course_filter = PipelineCourseFilter.find_or_create_by_service_learning_course_id params[:id]
      @filters = @pipeline_course_filter.filters.nil? ? {} : @pipeline_course_filter.filters
      
      filter_search
    end

    respond_to do |format|
      format.html # show.html.erb
      format.js   { render :partial => "admin/service_learning/courses/tabs/#{params[:tab]}" and return if params['tab'] }
      format.xml  { render :xml => @service_learning_course }
      format.pdf
    end
  end
=begin
  def filters
    @service_learning_course = ServiceLearningCourse.find params[:id]
    @pipeline_course_filter = PipelineCourseFilter.find_or_create_by_service_learning_course_id params[:id]
    @filters = @pipeline_course_filter.filters
    
    @subjects = PipelinePositionsSubject.find(:all,:order=>"name")
    @grades = PipelinePositionsGradeLevel.all
    @formats = PipelinePositionsTutoringType.find(:all,:order=>"name")
    
    @schools = School.find(:all,:order => "organizations.name")
    
    @neighborhoods = @schools.collect{|school| school.locations[0].neighborhood rescue nil}.compact.uniq.sort
    
    session[:breadcrumbs].add @service_learning_course.title, service_learning_course_path(@unit, @quarter, @service_learning_course) rescue nil
    session[:breadcrumbs].add "Filters", filters_service_learning_course_path(@unit, @quarter, @service_learning_course)
    
  end
=end
  def overview
    if params[:id]
      @service_learning_course = [ServiceLearningCourse.find(params[:id])]
    elsif params[:select]
      @service_learning_course = ServiceLearningCourse.find(params[:select].collect{|klass,select| select.collect{|id,value| id}}.flatten)
    end
    respond_to do |format|
      format.pdf
    end
  end
  
  def positions_print
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    render :action => 'positions_print', :layout => 'print_only'
  end

  # GET /service_learning_courses/new
  # GET /service_learning_courses/new.xml
  def new
    session[:breadcrumbs].add "New"
    @service_learning_course = ServiceLearningCourse.create :quarter_id => @quarter.id
    @service_learning_course.courses.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_learning_course }
    end
  end

  # GET /service_learning_courses/1/edit
  def edit
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    session[:breadcrumbs].add @service_learning_course.title, service_learning_course_path(@unit, @quarter, @service_learning_course) rescue nil
    session[:breadcrumbs].add "Edit"
  end

  # POST /service_learning_courses
  # POST /service_learning_courses.xml
  def create
    session[:breadcrumbs].add "New"
    @service_learning_course = ServiceLearningCourse.new(params[:service_learning_course])
    @service_learning_course.unit = @unit

    respond_to do |format|
      if @service_learning_course.save
        flash[:notice] = "#{@service_learning_course.title} was successfully created."
        format.html { redirect_to(service_learning_course_path(@unit, @quarter, @service_learning_course)) }
        format.xml  { render :xml => @service_learning_course, :status => :created, :location => @service_learning_course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_learning_course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_learning_courses/1
  # PUT /service_learning_courses/1.xml
  def update
    session[:breadcrumbs].add "Update"
    params[:service_learning_course][:existing_course_attributes] ||= {} if params[:remove_courses_if_needed]
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @service_learning_course.unit = @unit
    @service_learning_course.save

    respond_to do |format|
      if @service_learning_course.update_attributes(params[:service_learning_course])
        flash[:notice] = "#{@service_learning_course.title} was successfully updated."
        format.html { redirect_to(service_learning_course_path(@unit, @quarter, @service_learning_course)) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_learning_course.errors, :status => :unprocessable_entity }
        format.js   { render(:update) {|page| page.replace_html "organization_match_error", 
                          render(:inline => "<%= error_messages_for(:service_learning_course) %>") } }
        
      end
    end
  end

  # DELETE /service_learning_courses/1
  # DELETE /service_learning_courses/1.xml
  def destroy
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @service_learning_course.destroy

    respond_to do |format|
      format.html { redirect_to(service_learning_courses_url) }
      format.xml  { head :ok }
    end
  end

  def students
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    
    @positions = {}
    @service_learning_course.positions.open.each{|p| @positions[p] = p.placements.open_for(@service_learning_course).count }
    @placements = {}
          
    for placement in @service_learning_course.placements
      unless placement.position.organization.name == "Pipeline Project"
        if @placements[placement.person_id].nil?
          @placements[placement.person_id] = [placement]
        else
          @placements[placement.person_id] << placement
        end
      end
    end
        
    # Display Carlson pipeline project placements in pipeline roster students page, which allows pipeline staff 
    # to easily find the students who should be placed pipeline positions.
    pipeline_org = Organization.find_by_name("Pipeline Project") 
    pipeline_org_quarter = pipeline_org.organization_quarters.for_quarter(@quarter)
    pipeline_org_placements = pipeline_org_quarter.collect(&:positions).flatten.collect(&:placements).flatten
    
    for p in pipeline_org_placements
        if @placements[p.person_id].nil?
          @placements[p.person_id] = [p]
        else          
          @placements[p.person_id] << p
        end
    end        
        
    # Find the dropped placements and students
    @course_dropper_placements = ServiceLearningPlacement::Deleted.find_all_by_service_learning_course_id(@service_learning_course.id)     
    @course_droppers =  Person.find(@course_dropper_placements.collect(&:person_id).compact.uniq)
    @drop_placements = {}
    if @course_dropper_placements
      for drop in @course_dropper_placements 
        if @drop_placements[drop.person_id].nil?
          @drop_placements[drop.person_id] = [drop]
        else
          @drop_placements[drop.person_id] << drop
        end
      end
    end

    
            
    session[:breadcrumbs].add @service_learning_course.title, service_learning_course_path(@unit, @quarter, @service_learning_course) rescue "Detail"
    session[:breadcrumbs].add "Students"
  end
  
  def volunteers
    @volunteer_placements = ServiceLearningPlacement.find(:all, 
                                   :include => [{:position => [{:organization_quarter => :organization}]}, :person],
                                   :conditions => ["service_learning_placements.person_id IS NOT NULL AND
                                                    service_learning_placements.service_learning_course_id IS NULL AND
                                                    service_learning_positions.unit_id = :unit_id AND
                                                    organization_quarters.quarter_id = :quarter_id",
                                                    {:unit_id => @unit.id, :quarter_id => @quarter.id}])
                                                    
    session[:breadcrumbs].add "Volunteers"
  end
  
  # Places a student into a specific position for this course.
  def place
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @student = Person.find(params[:manually_register][:student_id] || params[:student_id])
    @position = ServiceLearningPosition.find(params[:manually_register][:position_id])
    @course = @service_learning_course.courses.find(params[:course]) rescue nil if params[:course]
    unless @student.nil? || @position.nil?
      if @student.place_into(@position, 
                          @service_learning_course, 
                          @unit,
                          params[:manually_register][:update_risk_paper_date], 
                          (params[:manually_register][:send_confirmation_email][@student.id.to_s] rescue false))
        flash[:notice] = "Successfully placed #{@student.fullname} into #{@position.title}."
      else
        flash[:error] = "There was an error placing the student."
        @errors = true
      end
    else
      flash[:error] = "Could not place student."
      @errors = true
    end
    @positions = {}
    @service_learning_course.positions.open.each{|p| @positions[p] = p.placements.open_for(@service_learning_course).count }
    @placements = {@student.id => @student.service_learning_placements.for(@service_learning_course, @unit)}
    
    respond_to do |format|
      format.html { redirect_to students_service_learning_course_path(@unit, @quarter, @service_learning_course) }
      format.js
    end
    
  end
  
  # Unplaces a student from any positions for this course.
  def unplace
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @student = Person.find(params[:student_id])
    @course = @service_learning_course.courses.find(params[:course]) if params[:course] && !@service_learning_course.courses.empty?
    @position_ids = []
    unless @student.nil?
      @student.service_learning_placements.for(@service_learning_course, @unit).each do |placement|
        @position_ids << placement.service_learning_position_id
        placement.unplace_student!
      end
      flash[:notice] = "Successfully removed #{@student.fullname} from service-learning position."
    else
      flash[:error] = "Could not unregister student."
      @errors = true
    end
    @positions = {}
    @service_learning_course.positions.open.each{|p| @positions[p] = p.placements.open_for(@service_learning_course).count }
    @placements = nil
    
    respond_to do |format|
      format.html { redirect_to students_service_learning_course_path(@unit, @quarter, @service_learning_course) }
      format.js
    end
    
  end
  
  # Adds a paper risk form to a student
  def add_paper_risk
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @student = Student.find(params[:student_id])
    unless @student.nil?
      @student.update_attribute(:service_learning_risk_paper_date, params[:date])
      flash[:notice] = "Successfully added paper AOR to #{@student.fullname}."
    else
      flash[:error] = "Error adding paper AOR date. Is that a valid Student ID?"
    end
    
    respond_to do |format|
      format.html { redirect_to students_service_learning_course_path(@unit, @quarter, @service_learning_course) }
      format.js
    end
    
  end
  
  def add_note
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @note = @service_learning_course.notes.create(params[:note])
    
    respond_to do |format|
      format.html { redirect_to service_learning_course_path(@unit, @quarter, @service_learning_course) }
      format.js
    end
  end
  
  def finalize
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @service_learning_course.toggle_finalized
    respond_to do |format|
      format.html { redirect_to redirect_to_path || {:action => "index"} }
      format.js
    end
  end
  
  def open
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @service_learning_course.toggle_open
    respond_to do |format|
      format.html { redirect_to redirect_to_path || {:action => "index"} }
      format.js
    end
  end

  def toggle_finalized
    params[:select].each do |obj_type,objects|
      objects.each do |obj_id,value|
        obj = eval("#{obj_type}.find(#{obj_id})")
        if obj.is_a? ServiceLearningCourse
          new_value = params[:value] || !obj.finalized?
          obj.toggle_finalized(new_value)
        end
      end
    end
    redirect_to :action => "index"
  end
  
  def toggle_open
    params[:select].each do |obj_type,objects|
      objects.each do |obj_id,value|
        obj = eval("#{obj_type}.find(#{obj_id})")
        if obj.is_a? ServiceLearningCourse
          new_value = params[:value] || !obj.open?
          obj.toggle_open(new_value)
        end
      end
    end
    redirect_to :action => "index"
  end

  def evaluation    
    @evaluation = @placement.evaluation    
    session[:breadcrumbs].add @service_learning_course.title, service_learning_course_path(@unit, @quarter, @service_learning_course) rescue nil
    session[:breadcrumbs].add "Students", students_service_learning_course_path(@unit, @quarter, @service_learning_course)
    session[:breadcrumbs].add "Evaluation"
  end

  def submit_evaluation
    @evaluation = @placement.evaluation || @placement.create_evaluation
    @evaluation.unsubmit if @evaluation.submitted?
    session[:breadcrumbs].add @service_learning_course.title, service_learning_course_path(@unit, @quarter, @service_learning_course) rescue nil
    session[:breadcrumbs].add "Students", students_service_learning_course_path(@unit, @quarter, @service_learning_course)
    session[:breadcrumbs].add "Submit Evaluation"
    
    if params[:evaluation]
      @evaluation.attributes = params[:evaluation]
      if @evaluation.save && @evaluation.update_attribute(:submitted_at, Time.now)
        flash[:notice] = "Evaluation submitted."
        return redirect_to :action => 'evaluation'
      else
        flash[:error] = "You have not submitted all the required fields."
        @show_errors = true
      end
    end
  end
  
  def unsubmit_evaluation
    @evaluation = Evaluation.find(params[:id])
    @service_learning_course = @evaluation.evaluatable.course
    @evaluation.unsubmit
    flash[:notice] = "The evaluation was successfully unsubmitted. Please notify the community partner to re-submit it."
    redirect_to students_service_learning_course_path(@unit, @quarter, @service_learning_course)
  end
  
  # No need for this method because students can always make changes to their logs after submission
  # def unsubmit_tutoring_log
  #   @placement = ServiceLearningPlacement.find(params[:id])    
  #   @service_learning_course = params[:course_id]
  #   @placement.update_attribute(:tutoring_submitted_at, nil)
  #   flash[:notice] = "The student tutoring log was successfully unsubmitted. Please notify the student to re-submit it."
  #   redirect_to students_service_learning_course_path(@unit, @quarter, @service_learning_course)
  # end
  

  def course_numbers
    render :partial => "course_numbers_dropdown", :locals => { :dept_abbrev => params[:dept_abbrev] }
  end
  
  def section_ids
    render :partial => "section_ids_dropdown", :locals => { :dept_abbrev => params[:dept_abbrev], :course_no => params[:course_no] }
  end

  def cross_listeds
    branch = params[:dept_abbrev] ? (Curriculum.find_by_curric_abbr(params[:dept_abbrev]).try(:curric_branch) || 0) : 0 rescue 0
    @course = Course.find(@quarter.year, @quarter.quarter_code_id, branch, params[:course_no], params[:dept_abbrev], params[:section_id])
    cross_listed_text = "(Cross-listed with #{@course.joint_listed_with})" if @course && @course.joint_listed?
    render :text => cross_listed_text
  end

  def delete_organization_match
    @service_learning_course = ServiceLearningCourse.find params[:id]

    if params[:organization_quarter_id]
      @service_learning_course.delete_potential_organization_match(params[:organization_quarter_id])
      flash[:notice] = "Removed potential course match."
    end

    respond_to do |format|
      format.html { redirect_to :action => "show" }
      format.js   { }
    end
  end
  
  # Sets if the course uses pipeline filters or not
  # If the course does noe use pipeline filters than it acts like a service learning course and must have slots made for it
  def toggle_use_filters
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @service_learning_course.no_filters = ((params[:checked] == "true") ? true : false)
    @service_learning_course.save
    
    unless @service_learning_course.no_filters
      @pipeline_course_filter = PipelineCourseFilter.find_or_create_by_service_learning_course_id params[:id]
      @filters = @pipeline_course_filter.filters.nil? ? {} : @pipeline_course_filter.filters
      
      filter_search
    end
    
    
    respond_to do |format|
      format.js
    end
  end
  
  # Updates the course's pipeline filters 
  def update_filters
    @pipeline_course_filter = PipelineCourseFilter.find_by_service_learning_course_id params[:id]
    
    @pipeline_course_filter.filters = params["search"]
    @pipeline_course_filter.save
    
    @service_learning_course = @pipeline_course_filter.service_learning_course
    
    @filters = @pipeline_course_filter.filters
    
    filter_search
    
    respond_to do |format|
      format.js
      format.html { redirect_to(service_learning_course_path(@unit, @quarter, @service_learning_course)) }
    end
  end
  
  # Grabs the positions that are associated with the course through the use of its pipeline filters
  def get_pipeline_positions
    @service_learning_course = ServiceLearningCourse.find(params[:id])
    @pipeline_course_filter = PipelineCourseFilter.find_or_create_by_service_learning_course_id params[:id]
    @filters = @pipeline_course_filter.filters.nil? ? {} : @pipeline_course_filter.filters
    
    filter_search
    
    respond_to do |format|
      format.js
    end
  end
  
  # Places a student in a position for a pipeline course and will create a placement if the course allows it
  def place_pipeline_position
    @student = Student.find params[:student_id]
    @pipeline_position = ServiceLearningPosition.find(params[:position_id])
    @service_learning_course = ServiceLearningCourse.find(params[:course_id])
    send_confirmation_email = params[:send_confirmation_email] == "true" ? "2" : false
    
    if !@student.place_into!(@pipeline_position, @service_learning_course, @unit, false, send_confirmation_email, !@pipeline_position.use_slots)
      @error_message = "Something when wrong when the student was placed."
    end
    
    @course = ServiceLearningCourseCourse.find @service_learning_course.students[@student.id][:course_id] rescue nil
    @positions = {}
    @placements = {@student.id => @student.service_learning_placements.for(@service_learning_course, @unit)}
    
    respond_to do |format|
	    format.js
    end
  end
  
  # Clone selected positions and placements(registered students who are) of the course for multiple quarters commitments
  # Multiple quarter includes 2~3 quarter depends on courses.
  def clone_positions_for_multiple_quarters
    @service_learning_course = ServiceLearningCourse.find(params[:course])
    @selected_copy_quarter = Quarter.find(params[:copy_quarter_id])
    @selected_copy_course = ServiceLearningCourse.find(params[:copy_course_id])
    
    if params[:select]
        copied_positions = []
        copied_placements = []
        for object_type, ids in params[:select]
          if object_type == 'ServiceLearningPosition'
            for id, val in ids
              position = ServiceLearningPosition.find(id)
              organization_quarter = position.organization_quarter
              begin 
                ActiveRecord::Base.transaction do                
                  @new_oq = OrganizationQuarter.find_by_organization_id_and_quarter_id_and_unit_id(position.organization.id, @selected_copy_quarter.id, @unit)
                    if @new_oq.nil?
                       @new_oq = organization_quarter.deep_clone!
                       @new_oq.update_attribute(:quarter_id, @selected_copy_quarter.id)
                       @new_oq.save!
                    end                                                                                           
                                        
                    @new_position = position.clone(['details','times','supervisor','location','approved','ideal_number_of_slots'])
                    @new_position.update_attribute(:organization_quarter_id, @new_oq.id)
                    @new_position.save!
                                                                               
                    position.placements.for(@service_learning_course).select(&:filled?).each do |placement|                        
                       new_placement = placement.deep_clone!
                       new_placement.update_attribute(:service_learning_position_id, @new_position.id)
                       new_placement.update_attribute(:service_learning_course_id, @selected_copy_course.id)
                       new_placement.save!
                       copied_placements << new_placement                   
                    end
                end                
              rescue ActiveRecord::RecordInvalid => invalid                  
                raise ActiveRecord::Rollback
                flash[:error] = "Sorry, but we couldn't copy #{position.name}. An error occurred."                                                 
                redirect_to :back
              end
              @new_oq.update_position_counts!                                                 
              copied_positions << @new_position
            end
          end
        end
      flash[:notice] = "Copied #{copied_positions.size} positions with #{copied_placements.size} students who enrolled #{@service_learning_course.title} to #{@selected_copy_quarter.title}."
    else
      flash[:error] = "Please select at least one position first."
      redirect_to :back    
    end
    respond_to do |format|
      #format.html { redirect_to(service_learning_course_path(@unit, @quarter, @service_learning_course, :anchor => "organization_matches")) }
      format.html { redirect_to(service_learning_course_path(@unit, @selected_copy_quarter, @selected_copy_course, :anchor => "position_matches")) }
    end  

  end  
  
  # Copy the course to chosen quarter
  def clone_course     
    if params[:copy_course_id]
      @service_learning_course ||= ServiceLearningCourse.find(params[:copy_course_id])
    
      if slc2 = @service_learning_course.deep_clone!
        slc2.update_attribute(:quarter_id, @quarter.id)
        flash[:notice] = "Successfully cloned #{@service_learning_course.title} for #{slc2.quarter.title}. You can customize the details below."        
        redirect_to edit_service_learning_course_path(@unit, slc2.quarter, slc2)
      else
        flash[:error] = "Sorry, but we couldn't copy that course. An error occurred."
        redirect_to :back
      end
    end    
  end
  
  def change_quarter_option
    #redirect_to :action => "index", :copy_quarter_id => params[:copy_quarter_id]
    render :partial => "course_copy_dropdown"
  end
      
  private
  
  # Performs the search to find the positions for the pipeline course
  def filter_search
    @subjects = PipelinePositionsSubject.find(:all,:order=>"name")
    @grades = PipelinePositionsGradeLevel.all
    @formats = PipelinePositionsTutoringType.find(:all,:order=>"name")
    
    @schools = School.find(:all,:order => "organizations.name")

    @neighborhoods = @schools.collect{|school| school.locations[0].neighborhood rescue nil}.compact.uniq.sort
    
    @pipeline_positions = generate_pipeline_search(true)
  end
  
  def courses_breadcrumbs
    session[:breadcrumbs].add "Courses", service_learning_courses_path
  end
  
  def get_tutoring_logs
    @placement = ServiceLearningPlacement.find(params[:id])
    @service_learning_course = @placement.course    
    @is_pipeline = Unit.find(@placement.unit_id).abbreviation == "pipeline" ? true : false
    @tutoring_logs = @placement.tutoring_logs.sort_by(&:log_date) if @is_pipeline    
  end

  def generate_copy_options
      if params[:action] == "index" || params[:action] == "change_quarter_option" || (params[:action] == "show" && (params[:tab] || params[:tab] == "multipal_quarter"))
          @copy_quarter_options = []
          for quarter in ServiceLearningCourse.all.collect(&:quarter).uniq.sort.reverse
            key = "#{quarter.title}"
            value = quarter.id
            @copy_quarter_options << [key, value]
          end
          
          @copy_quarter = Quarter.find params[:copy_quarter_id] || (params[:action] == "show" ? @quarter.next : @quarter.prev)
    
          @copy_courses_options = []
          for service_learning_course in @copy_quarter.service_learning_courses.for_unit(@unit).sort
            key = "#{service_learning_course.title}"
            value = service_learning_course.id
            @copy_courses_options << [key, value]
          end
      end
  end

end
