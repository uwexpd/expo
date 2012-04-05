class Accountability::Reporting::CoursesController < Accountability::ReportingController
  before_filter :add_courses_breadcrumbs
  before_filter :check_finalized, :only => [:mass_add, :mass_create, :create, :update, :destroy]
  skip_before_filter :fetch_service_learning_courses, :except => [:index]
  
  def index
    @activities = {}
    @activity_types.each{|a| @activities[a.id] ||= {}; @quarters.each{|q| @activities[a.id][q.id] ||= [] } }
    ActivityCourse.for_quarter_and_department(@quarters, @department).each{|a| @activities[a.activity_type_id][a.quarter_id] << a}

    @last_years_activities = {}
    @activity_types.each{|a| @last_years_activities[a.id] ||= [] }
    ActivityCourse.for_quarter_and_department(@last_years_quarters, @department).each{|a| @last_years_activities[a.activity_type_id] << a.course.short_title }
    
  end

  # def show
  #   @activity = ActivityCourse.find(params[:id])
  #   session[:breadcrumbs].add "#{@activity.title}"
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @activity }
  #   end
  # end

  # def new
  #   @activity = ActivityCourse.new
  #   session[:breadcrumbs].add "New"
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @activity }
  #   end
  # end

  # def edit
  #   @activity = ActivityCourse.find(params[:id])
  #   session[:breadcrumbs].add "#{@activity.title}", @activity
  #   session[:breadcrumbs].add "Edit"
  # end

  def mass_add
    raw_course_abbrevs = params[:course_abbrevs] || []
    raw_course_abbrevs = raw_course_abbrevs.split(/[\n,]/).collect(&:strip).reject{|a| a.blank?}.uniq unless raw_course_abbrevs.is_a?(Array)
    @courses = {}
    
    for abbrev in raw_course_abbrevs
      match = Course.match(abbrev)
      result = {}
      if match.nil?
        result[:courses] = nil
        result[:message] = "Invalid format"
      else
        result[:courses] = {}
        courses = Course.find_all_by_short_title(match[1], match[2], @quarters, :section_id => match[3])
        for course in courses
          empty_quarters_hash = {}
          result[:courses][course.short_title] ||= {}
          result[:courses][course.short_title][course.quarter] = course
        end
        result[:courses] = result[:courses].sort_by{|k,v| k}
      end
      @courses[abbrev] = result
    end 

    session[:breadcrumbs].add "Mass Add"
  end
  
  def mass_create
    @success = []
    @errors = []
    @dupes = []
    for course_id in params[:course_ids]
      if course = Course.find(course_id)
        attributes = {
          :department_id => course.department.try(:id),
          :title => course.course_title,
          :quarter_id => course.quarter.id,
          :course_branch => course.course_branch,
          :course_no => course.course_no,
          :dept_abbrev => course.dept_abbrev,
          :section_id => course.section_id,
          :preparer_uw_netid => current_user.login,
          :activity_type_id => params[:activity_type_id]
        }
        unless @department.is_a?(Department) && @department.id == course.department.try(:id)
          attributes[:reporting_department_id] = @department.dept_code unless @department.dept_code.blank?
          attributes[:reporting_department_name] = @department.fixed_name if @department.dept_code.blank?
        end
        if @accountability_reports[params[:activity_type_id].to_i] && @accountability_reports[params[:activity_type_id].to_i].finalized?
          @errors << activity
          next
        end
        activity = ActivityCourse.new(attributes)
        if activity.save
          @success << activity
        else
          @errors << activity
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
    end
  end

  def create
    @activity = ActivityCourse.new(params[:activity])
    raise "Access denied" unless @activity.belongs_to_department?(@department)

    respond_to do |format|
      if @activity.save
        flash[:notice] = "ActivityCourse was successfully created."
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    @activity = ActivityCourse.find(params[:id])
    raise "Access denied" unless @activity.belongs_to_department?(@department)

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = "ActivityCourse was successfully updated."
        format.html { redirect_to(@activity) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @activity = ActivityCourse.find(params[:id])
    raise "Access denied" unless @activity.belongs_to_department?(@department)
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to(admin_activities_url) }
      format.xml  { head :ok }
      format.js
    end
  end

  # def course_numbers
  #   render :partial => "course_numbers_dropdown", :locals => { :dept_abbrev => params[:dept_abbrev] }
  # end
  # 
  # def section_ids
  #   render :partial => "section_ids_dropdown", :locals => { :dept_abbrev => params[:dept_abbrev], :course_no => params[:course_no] }
  # end
  # 
  # def cross_listeds
  #   branch = params[:dept_abbrev] ? (Major.find_by_abbrev(params[:dept_abbrev]).try(:major_branch) || 0) : 0 rescue 0
  #   @course = Course.find(@quarter.year, @quarter.quarter_code_id, branch, params[:course_no], params[:dept_abbrev], params[:section_id])
  #   cross_listed_text = "(Cross-listed with #{@course.joint_listed_with})" if @course && @course.joint_listed?
  #   render :text => cross_listed_text
  # end
  # 
  
  protected
  
  def add_courses_breadcrumbs
    session[:breadcrumbs].add "Courses", accountability_reporting_courses_url(@year)
  end
end