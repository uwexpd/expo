class Admin::InterviewerController < Admin::BaseController
  before_filter :add_to_breadcrumbs
  before_filter :fetch_offering

  def index
    @interviewers = @offering.interviewers
  end

  def show
    session[:breadcrumbs].add "Detail"
    @interviewer = @offering.interviewers.find params[:id]
  end

  def availability
    session[:breadcrumbs].add "Availability"
    @interviewer = @offering.interviewers.find params[:id]
  end
  
  def print_availabilities
    @interviewers = @offering.interviewers.select{|i| i.responded_with_availability? }
    render :action => "print_availabilities", :layout => 'print_only'
  end
  
  # Marks a person available for a specific interview timeslot
  def mark_available
    @interviewer = @offering.interviewers.find params[:id]
    t = @interviewer.interview_availabilities.find_or_create_by_time_and_offering_interview_timeblock_id(
                                                                          params[:time].to_time, params[:timeblock_id])
    render :partial => "apply/timeslot_available", 
            :locals => { :b => params[:timeblock_id], :ti => params[:ti], :time => params[:time], :view_only => !params[:edit] }
  end
  
  # Marks a person as unavailable for a specific interview timeslot
  def mark_unavailable
    @interviewer = @offering.interviewers.find params[:id]
    t = @interviewer.interview_availabilities.find_by_time_and_offering_interview_timeblock_id(
                                                                params[:time].to_time, params[:timeblock_id])
    t.destroy
    render :partial => "apply/timeslot_not_available", 
            :locals => { :b => params[:timeblock_id], :ti => params[:ti], :time => params[:time], :view_only => !params[:edit] }
  end
  
  protected
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    session[:breadcrumbs].add @offering.name, admin_apply_path(@offering)
    session[:breadcrumbs].add @offering.quarter_offered.title, admin_apply_path(@offering)
  end

  def add_to_breadcrumbs
    session[:breadcrumbs].add "Interviewers", "/admin/interviewer"
  end
  
end
