class Admin::InterviewController < Admin::BaseController
  before_filter :add_to_breadcrumbs
  before_filter :fetch_offering
  
  def index
    @interviews = @offering.interviews.sort {|x,y| x.start_time <=> y.start_time }
  end
  
  def new
    session[:breadcrumbs].add "Add New"
  end
  
  def create
    @interview = @offering.interviews.create params[:offering_interview]
    if @interview.save
      unless params[:offering_interview][:applicant_id].blank?
        @interview.applicants.create :application_for_offering_id => params[:offering_interview][:applicant_id]
      end
      if params[:interviewers]
        params[:interviewers].each do |i|
          @interview.interviewers.create :offering_interviewer_id => i
        end
      end
      flash[:notice] = "Successfully created interview time."
      redirect_to :action => "index"
    else
      render :action => 'new'
    end
  end

  def edit
    session[:breadcrumbs].add "Edit"
    @interview = @offering.interviews.find_by_id params[:id]
  end
  
  def update
    @interview = @offering.interviews.find_by_id params[:id]
    @interview.attributes = params[:offering_interview]
    if @interview.save
      @interview.applicants.delete_all
      @interview.interviewers.delete_all
      unless params[:offering_interview][:applicant_id].blank?
        @interview.applicants.create :application_for_offering_id => params[:offering_interview][:applicant_id]
      end
      if params[:interviewers]        
        params[:interviewers].each do |i|
          @interview.interviewers.create :offering_interviewer_id => i
        end
      end
      flash[:notice] = "Successfully saved interview time information."
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def show
    session[:breadcrumbs].add "Detail"
  end
  
  def destroy
    OfferingInterview.find(params[:id]).destroy
    render :partial => "interview_list"
  end
  
  protected
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    session[:breadcrumbs].add @offering.name, admin_apply_path(@offering)
    session[:breadcrumbs].add @offering.quarter_offered.title, admin_apply_path(@offering)
  end

  def add_to_breadcrumbs
    session[:breadcrumbs].add "Interviews", "/admin/intervew"
  end

end
