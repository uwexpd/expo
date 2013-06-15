class Accountability::ReportingController < AccountabilityController
  before_filter :login_required
  before_filter :add_reporting_breadcrumbs
  
  before_filter :check_department_authorizations
  before_filter :fetch_department, :except => [:choose_department]
  before_filter :fetch_year_and_related, :except => [:choose_department]
  before_filter :fetch_service_learning_courses, :only => [:index]  
  
  layout 'admin'

  def index
    puts "department: "
    pp @department
        
    @course_activity_type_ids = ActivityCourse.for_quarter_and_department(@quarters, @department).collect(&:activity_type_id)
    @individual_activity_type_ids = ActivityProject.for_quarter(@quarters).for_department(@department).collect(&:activity_type_id)        
  end

  def individuals
  end
  
  def summary
  end
  
  def restricted    
  end
  
  def choose_department
    if params[:accountability_department_authid]
      session[:accountability_department_authid] = params[:accountability_department_authid]
      return redirect_to :action => 'index'
    end
  end
  
  protected
  
  def check_department_authorizations
    @my = current_user
    @department_authorizations = @my.authorizations_for(:accountability_department_coordinator)
    return render :action => "restricted" if @department_authorizations.nil? || @department_authorizations.empty?
  end
  
  def fetch_department
    unless session[:accountability_department_authid]
      if @department_authorizations.size == 1
        session[:accountability_department_authid] = @department_authorizations.first.id
      else
        return redirect_to :action => "choose_department"
      end
    end
    @department = @department_authorizations.find{|a| a.id == session[:accountability_department_authid].to_i }.authorizable rescue nil
    return redirect_to :action => "choose_department" if @department.nil?
  end

  def fetch_year_and_related
    @year = params[:year].to_i.zero? ? Time.now.year : params[:year].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @last_years_quarter_abbrevs = ["SUM#{@year-2}", "AUT#{@year-2}", "WIN#{@year-1}", "SPR#{@year-1}"]
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)
    @last_years_quarters = Quarter.find_by_abbrev(@last_years_quarter_abbrevs)
    @activity_types = ActivityType.all
    @accountability_reports = {}
    for activity_type in @activity_types
      ar = AccountabilityReport.find_or_create_by_year_and_quarter_abbrevs_and_activity_type_id(
                                                    @year, @quarter_abbrevs.join(" "), activity_type.id)
      @accountability_reports[activity_type.id] = ar
    end
    @finalized = @accountability_reports.values.collect(&:finalized).include?(true) # just say everything's final, even if one isn't.
    session[:breadcrumbs].add @year.to_s, accountability_reporting_path(:year => @year)
  end

  # Display the totals by courses for ServiceLearningPlacement in a specific department
  def fetch_service_learning_courses    
    @service_learning_courses ||= {}
    @service_learning_courses_total = 0
    @activity_types.each{|a| @service_learning_courses[a.id] ||= {}; @quarters.each{|q| @service_learning_courses[a.id][q.id] ||= [] } }
    activity_type_id = ActivityType.find_by_title("Public Service").id
    
    @accountability_report = AccountabilityReport.find_by_year_and_quarter_abbrevs_and_activity_type_id(@year, @quarter_abbrevs.join(" "), activity_type_id)
    @report = @accountability_report.service_learning_course_statistics(@department) unless @accountability_report.in_progress?
    
    unless @report[:department]["#{@department.dept_code}_#{@department.name}"].blank?      
      for q in @quarters
          @service_learning_courses[activity_type_id][q.id] = @report[:department]["#{@department.dept_code}_#{@department.name}"][:quarters][q.abbrev][:courses] 
          @service_learning_courses_total += @service_learning_courses[activity_type_id][q.id].size
      end
    end
    
  end
  
  def check_finalized
    if @finalized
      flash[:error] = "You cannot report new information or make changes because this accountability report is finalized."
      return redirect_to(:back)
    end
  end
  
  def add_reporting_breadcrumbs
    session[:breadcrumbs].add "Accountability", accountability_path
    session[:breadcrumbs].add "Reporting", accountability_reporting_path
  end
  
end