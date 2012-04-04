class AccountabilityController < ApplicationController
  skip_before_filter :login_required
  layout 'admin'
  
  # Disable highchart function because conflict of prototype.js and JQuery
  #uses_highcharts

  before_filter :initialize_breadcrumbs
  helper_method :get_breadcrumbs
  def get_breadcrumbs
    breadcrumbs
  end
  
  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXPO Admin Area", admin_welcome_url, {:class => "home"}
    # session[:breadcrumbs].add "Accountability Reporting", accountability_path
  end

  def index    
    
    @years = AccountabilityReport.years
    session[:breadcrumbs].add "Accountability"
    
    @students_data = []
    @student_quarters_data = []
    @hours_data = []
    
    @activity_types = ActivityType.all
    @draft_years = []
    
    for activity_type in @activity_types
      students_data         = { :name => activity_type.title, :data => [] }
      student_quarters_data = { :name => activity_type.title, :data => [] }
      hours_data            = { :name => activity_type.title, :data => [] }
      
      for year in @years
        quarter_abbrevs = ["SUM#{year-1}", "AUT#{year-1}", "WIN#{year}", "SPR#{year}"]
        ar = AccountabilityReport.find_or_create_by_year_and_quarter_abbrevs_and_activity_type_id(
              year, quarter_abbrevs.join(" "), activity_type.id)
        @draft_years << year unless ar.finalized

        totals = ar.final_statistics[:total]
        students_data[:data]          << totals[:number_of_students]
        student_quarters_data[:data]  << totals[:student_quarters]
        hours_data[:data]             << totals[:number_of_hours]
      end
      
      @students_data          << students_data
      @student_quarters_data  << student_quarters_data
      @hours_data             << hours_data
    end
  end

  def year
    @year = params[:id].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @activity_types = ActivityType.all
    @reports = {}
    @report_objects = {}
    for activity_type in @activity_types
      # @reports[activity_type] = AccountabilityReport.new(@quarter_abbrevs, activity_type.abbreviation).final_statistics
      ar = AccountabilityReport.find_or_create_by_year_and_quarter_abbrevs_and_activity_type_id(@year, @quarter_abbrevs.join(" "), activity_type.id)
      @reports[activity_type] = ar.final_statistics unless ar.in_progress?
      @report_objects[activity_type] = ar
    end
    @colleges = {}
    for activity_type, report in @reports
      for department_id, results in report[:department]
        m = department_id.match(/^([E\d]+)_(.+)/) rescue nil
        if m && m[1] != "0" && m[1] != "E"
          department = Department.find(m[1])
          college_name = department.college.try(:name)
          department_name = department.name
        elsif m
          college_name = "Other"
          department_name = m[2]
        else
          college_name = "Other"
          department_name = "Unknown"          
        end
        @colleges[college_name] ||= { :department => {} }
        @colleges[college_name][:department][department_name] ||= {}
        @colleges[college_name][:department][department_name][activity_type] = results
      end
    end
    
    session[:breadcrumbs].add "Accountability", accountability_path
    session[:breadcrumbs].add "#{@year.to_s} Accountability Report"
    
    respond_to do |format|
      format.html
      format.xls  { render :action => 'year', :layout => 'basic' }
    end
  end
  
end