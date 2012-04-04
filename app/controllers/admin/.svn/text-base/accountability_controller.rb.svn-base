class Admin::AccountabilityController < Admin::BaseController
  before_filter :accountability_breadcrumbs
  require_role :accountability_manager

  def index
    @years = AccountabilityReport.years.reverse
  end

  def status
    @year = params[:id].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)
    
    @departments = {}
    @activity_types = ActivityType.all
    
    @activities = ActivityCourse.for_quarter(@quarters) + ActivityProject.for_quarter(@quarters)
    
    for activity in @activities
      department = activity.try(:department) || activity.department_name
      department_object = department.is_a?(String) ? DepartmentExtra.find_or_create_by_fixed_name(department) : department
      unless @departments[department]
        @departments[department] = {}
        # @activity_types.each{|at| @departments[department][at.id] = {:courses => [], :individuals => []}}
        @activity_types.each{|at| @departments[department][at.id] = {:courses => 0, :individuals => 0}}
      end
      klass = activity.is_a?(ActivityCourse) ? :courses : :individuals
      # @departments[department][activity.activity_type_id][klass] << activity
      @departments[department][activity.activity_type_id][klass] += 1
      @departments[department][:department_object] = department_object
    end
    
    session[:breadcrumbs].add "Reporting Status (#{@year})"
  end

  def courses
    @year = params[:id].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)
    @department = params[:department_key].match(/^\d+/) ? Department.find(params[:department_key]) : params[:department_key]
    @activity_types = ActivityType.all
    @activities = {}
    @activity_types.each{|a| @activities[a.id] ||= {}; @quarters.each{|q| @activities[a.id][q.id] ||= [] } }
    ActivityCourse.for_quarter_and_department(@quarters, @department).each{|a| @activities[a.activity_type_id][a.quarter_id] << a}
    
    session[:breadcrumbs].add "Reporting Status (#{@year})", :action => "status", :id => @year
    session[:breadcrumbs].add "#{@department.try(:name) rescue @department}"
  end

  def individuals
    @year = params[:id].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)
    @department = params[:department_key].match(/^\d+/) ? Department.find(params[:department_key]) : params[:department_key]
    @activity_types = ActivityType.all
    @activities = {}
    for activity_type in @activity_types
      @activities[activity_type.id] = ActivityProject.for_quarter(@quarters).for_department(@department).of_type(activity_type).find(:all, :include => [:quarters])
    end
    
    session[:breadcrumbs].add "Reporting Status (#{@year})", :action => "status", :id => @year
    session[:breadcrumbs].add "#{@department.try(:name) rescue @department}"
  end

  def regenerate
    @report = AccountabilityReport.find(params[:id])

    AccountabilityReport.mark_as_in_progress(params[:id])
    
    logger.info { "Initiating fork for accountability:regenerate_report" }
    @pid = fork do
      cmd = "rake accountability:regenerate_report REPORT_ID=#{@report.id} RAILS_ENV=#{RAILS_ENV}"
      system cmd
      exit! 127
    end
    Process.detach(@pid)
    
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
    end    
  end
  
  def regenerate_status
    @complete = !AccountabilityReport.in_progress?(params[:id])
    
    respond_to do |format|
      format.js
    end
  end

  protected
  
  def accountability_breadcrumbs
    session[:breadcrumbs].add "Accountability", admin_accountability_url
  end
  
end
