class InterviewerController < ApplicationController
  before_filter :fetch_offering, :fetch_person
  before_filter :fetch_offering_interviewer, :except => [:inactive]
  before_filter :check_if_contact_info_is_current, :except => [:update, :inactive]
  before_filter :initialize_breadcrumbs

  helper 'admin/base'
  layout 'admin'

  def index
    @interviews = @offering_interviewer.offering_interviews
    @interviews.sort! { |x,y| x.start_time <=> y.start_time }
    
    render :action => 'index_scored', :layout => @layout if @offering.uses_scored_interviews?
  end

  def show
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id

    session[:breadcrumbs].add @app.fullname

    # Initialize score card if needed
    @offering_interview_interviewer.create_scores unless @viewing_past_app

    if params['section']
      return render :partial => "review_committee", :locals => { :audience => :reviewer } if params[:section] == 'review_committee'
      return render :partial => "admin/apply/section/#{params[:section]}", :locals => { :audience => :reviewer } 
    else
      return render :action => 'show_scored', :layout => @layout if @offering.uses_scored_interviews?
    end
    
    if params['view'] == 'essay'
      file_path = File.join(RAILS_ROOT, 'files', @app.files.first.file.url)
      send_file file_path
    end
    if params['view'] == 'letter'
      file_path = File.join(RAILS_ROOT, 'files', @app.mentors.first.letter.url)
      send_file file_path
    end
  end
  
  def view
    # @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    # @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
    @app = ApplicationForOffering.find params[:id]
    if params[:file]
      file_path = File.join(RAILS_ROOT, 'files', @app.files.find(params[:file]).file.original.public_path)
    elsif params[:mentor]
      file_path = File.join(RAILS_ROOT, 'files', @app.mentors.find(params[:mentor]).letter.original.public_path)
    end
    send_file file_path unless file_path.nil?
  end
  
  def transcript
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
  end
  
  def comments
    if params[:offering_interview_interviewer]
      @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
      @offering_interview_interviewer.comments = params[:offering_interview_interviewer]['comments']
      @offering_interview_interviewer.save
      flash[:notice] = "Comments saved."
    end
    respond_to do |format|
      format.js   { render :text => "Comments saved at #{Time.now.to_s(:time)}."}
      format.html { redirect_to :action => "show", :id => @offering_interview_interviewer}
    end
  end
  
  def final_decision
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
    if params['application_for_offering']
      @app.set_status "interview_decision" unless @app.interview_decision_made?
      @app.attributes = params['application_for_offering']
      if @app.save
        flash[:notice] = "Decision and comments saved."
        redirect_to :action => 'index'
      else
        flash[:error] = "Could not save your decision or comments."
        render :action => "show"
      end
    end
  end

  def welcome
    if params[:welcome]
      unless params[:welcome][:special_notes].nil?
        @offering_interviewer.special_notes = params[:welcome][:special_notes]
        @offering_interviewer.save
        flash[:notice] = "Special requests and notes saved. Thank you."
      end
    end
    yes_option_id = @offering.application_review_decision_types.find_by_yes_option(true)
    @apps = @offering.applications_with_status("submitted")
    
    if params[:conflict_of_interests]
      @offering_interviewer.conflict_of_interests.destroy_all
      if params[:recuse]
        params[:recuse].each do |r|
          @offering_interviewer.conflict_of_interests.create(:application_for_offering_id => r)
        end
      end
      flash[:notice] = "Conflicts of interest saved. Thank you."
    end
    
    render :action => 'welcome', :layout => @layout
  end
  
  def update
    if params[:application_reviewer] # this is for the scored review version
      @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
      @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
      return redirect_to :action => "index" if @offering_interview_interviewer.finalized?
      if @offering_interview_interviewer.update_attributes params[:application_reviewer]
        flash[:notice] = "Review saved successfully."
        respond_to do |format|
          format.html { return redirect_to :action => 'index' }
          format.js   { return render :text => "Review auto-saved at #{Time.now.to_s(:time12)}." }
        end
      else
        flash[:error] = "Could not save your responses."
      end
    elsif params["person"]
      @person = @current_user.person
      @person.attributes = params["person"]
      @person.contact_info_updated_at = Time.now
      @person.require_validations = true
      if @person.save
        flash[:notice] = "Contact information saved. Thank you."
        redirect_to redirect_to_path || url_for(:action => "index")
      else
        # render "update"
      end
    end
  end
  
  def availability
    if params[:commit]
      flash[:notice] = "Thank you for submitting your availability! We will contact you as soon as interviews are scheduled."
    end
    # render availability.html.erb
  end
  
  # Marks a person available for a specific interview timeslot
  def mark_available
    t = @offering_interviewer.interview_availabilities.find_or_create_by_time_and_offering_interview_timeblock_id(
                                                                          params[:time].to_time, params[:timeblock_id])
    render :partial => "apply/timeslot_available", :locals => { :b => params[:timeblock_id], :ti => params[:ti], :time => params[:time] }
  end
  
  # Marks a person as unavailable for a specific interview timeslot
  def mark_unavailable
    t = @offering_interviewer.interview_availabilities.find_by_time_and_offering_interview_timeblock_id(
                                                                params[:time].to_time, params[:timeblock_id])
    t.destroy
    render :partial => "apply/timeslot_not_available", :locals => { :b => params[:timeblock_id], :ti => params[:ti], :time => params[:time] }
  end
  
  def inactive
    # render inactive.html.erb
  end
  
  def not_this_quarter
    @offering_interviewer.destroy unless @offering_interviewer.nil?
    flash[:notice] = "You have been removed from the list of interviewers for the current quarter. Thank you!"
    redirect_to :action => "inactive"
  end

  def composite_report
    if params[:include]
      @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
      @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id

      parts = []
      params[:include].each do |part,value|
        parts << part.to_sym
      end
      file = @app.composite_report(@offering_interview_interviewer).pdf(parts)
      unless file.is_a?(String)
        flash[:error] = "Sorry, but there was an error creating the file. (#{file.inspect})"
        redirect_to :action => "index" and return
      end
      send_file file, :disposition => 'attachment', :type => 'application/pdf' unless file.nil?
    else
      flash[:error] = "You have to identify which parts of the application to include."
      redirect_to :action => "show", :id => params[:id]
    end
  end

  def multi_composite_report
    if params[:include] && params[:format]
      parts = []
      params[:include].each do |part,value|
        parts << part.to_sym
      end
      @apps = @offering_interviewer.offering_interview_interviewers.collect(&:applicant)
      report = MultiApplicationCompositeReport.new(@offering, @apps.sort_by(&:fullname), parts)
      report.offering_interviewer = @offering_interviewer
      file = report.generate!(params[:format].to_sym)
      unless file.is_a?(String)
        flash[:error] = "Sorry, but there was an error creating the file. (#{file.inspect})"
        redirect_to :action => "index" and return
      end
      send_file file, :disposition => 'attachment', :type => "application/#{params[:format].to_sym}" unless file.nil?
    else
      flash[:error] = "You have to identify which parts of the application to include."
      redirect_to :action => "index"
    end
  end
  
  
  def criteria
    render :action => 'criteria', :layout => 'popup'
  end

  def finalize
    if params[:commit]
      for interviewer in @offering_interviewer.offering_interview_interviewers
        interviewer.update_attribute(:finalized, true) if interviewer.started_scoring? && !interviewer.finalized?
      end
    end
    flash[:notice] = "Thank you! Your finalized scores were submitted."
    redirect_to :action => "index"
  end
  
  protected
  
  def fetch_person
    @person = @current_user.person
  end
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    # @layout = @offering.uses_scored_interviews? ? 'admin' : 'public'
    @layout = 'admin'
  end

  def fetch_offering_interviewer
    @offering_interviewer = @person.offering_interviewers.find_by_offering_id(@offering)
    if @offering_interviewer.nil?
      redirect_to :action => "inactive"
    end
  end

  # Checks to see if the contact information for this mentor is current. This is done by checking for a value in
  # person.contact_info_updated_at. If it is blank or older than 3 months, then redirect to the "update" page.
  def check_if_contact_info_is_current
    update_date = @current_user.person.contact_info_updated_at
    if update_date.blank? || Time.now - update_date > 3.months
      redirect_to :action => "update", :return_to => request.request_uri
    end
  end

  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXP-Online", "/expo", {:class => "home"}
    session[:breadcrumbs].add "Interviewer Interface", interviewer_path(@offering)
    session[:breadcrumbs].add @offering.name, interviewer_path(@offering)
  end


end
