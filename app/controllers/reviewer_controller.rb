class ReviewerController < ApplicationController
  before_filter :fetch_person, :fetch_offering, :fetch_review_committee_member, :fetch_apps
  before_filter :fetch_app, :except => [:index, :criteria, :extra_instructions, :finalize, :multi_composite_report]
  before_filter :fetch_application_reviewer, :only => [:show, :update, :composite_report]
  before_filter :initialize_breadcrumbs
  # layout 'admin'
  helper 'admin/base'
  
  def index
    @apps = @apps.sort_by(&:fullname)
    render :action => 'index_scored', :layout => @layout if @offering.uses_scored_review?
  end

  def show
    session[:breadcrumbs].add @app.fullname

    # Initialize score card if needed
    @application_reviewer.create_scores unless @viewing_past_app

    if params['section']
      render :partial => "admin/apply/section/#{params[:section]}", :locals => { :audience => :reviewer } and return
    else
      render :action => 'show_scored', :layout => @layout and return if @offering.uses_scored_review?
    end
    
  end

  def transcript
    
  end

  def composite_report
    if params[:include]
      parts = []
      params[:include].each do |part,value|
        parts << part.to_sym
      end
      file = @app.composite_report(@application_reviewer).pdf(parts)
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
      report = MultiApplicationCompositeReport.new(@offering, @apps.sort_by(&:fullname), parts)
      report.review_committee_member = @review_committee_member
      file = report.generate!(params[:format].to_sym)
      unless file.is_a?(String)
        flash[:error] = "Sorry, but there was an error creating the file. (#{file.inspect})"
        if params[:reviewer]
          redirect_to :back and return 
        else
          redirect_to :action => "index" and return
        end
      end
      send_file file, :disposition => 'attachment', :type => "application/#{params[:format].to_sym}" unless file.nil?
    else
      flash[:error] = "You have to identify which parts of the application to include."
      if params[:reviewer] 
        redirect_to :back
      else 
        redirect_to :action => "index"
      end
    end
  end


  def view
    # if params[:file]
    #   file_path = File.join(RAILS_ROOT, 'files', @app.files.find(params[:file]).file.original.public_path)
    #   type = @app.files.find(params[:file]).file.content_type
    # elsif params[:mentor]
    #   file_path = File.join(RAILS_ROOT, 'files', @app.mentors.find(params[:mentor]).letter.original.public_path)
    #   type = @app.mentors.find(params[:mentor]).letter.content_type
    # end
    version = params[:version].nil? ? :original : params[:version].to_sym
    if params[:file]
      file = @app.files.find(params[:file]).file.versions[version]
      file_path = File.join(RAILS_ROOT, 'files', file.public_path)
      type = file.content_type
      filename = file.public_filename
    elsif params[:mentor]
      file = @app.mentors.find(params[:mentor]).letter.versions[version]
      file_path = File.join(RAILS_ROOT, 'files', file.public_path)
      type = file.content_type
      filename = file.public_filename
    end    
    disposition = params[:disposition] == 'inline' ? 'inline' : 'attachment'
    send_file file_path, :disposition => disposition, :type => (type || "text"), :filename => filename unless file_path.nil?
  end
  
  def criteria
    render :action => 'criteria', :layout => 'popup'
  end
  
  def extra_instructions
    render :action => "extra_instructions", :layout => 'popup'
  end
  
  def update
    if params[:application_reviewer] # this is for the scored review version
      return redirect_to :action => "index" if @application_reviewer.finalized?
      if @application_reviewer.update_attributes params[:application_reviewer]
        flash[:notice] = "Review saved successfully."
        respond_to do |format|
          format.html { return redirect_to :action => 'index' }
          format.js   { return render :text => "Review auto-saved at #{Time.now.to_s(:time12)}." }
        end
      else
        flash[:error] = "Could not save your responses."
      end
    end
    if params['application_for_offering'] # this is for the non-scored review version
      @app.set_status "reviewed" unless @app.reviewed? && @app.passed_status?("reviewed")
      @app.attributes = params['application_for_offering']
      if @app.save
        flash[:notice] = "Decision and comments saved."
        return redirect_to :action => 'index'
      else
        flash[:error] = "Could not save your decision or comments."
      end
    end
    return render :action => "show", :layout => @layout
  end
    
  def finalize
    if params[:commit]
      for application_reviewer in @application_reviewers
        application_reviewer.update_attribute(:finalized, true) if application_reviewer.started_scoring? && !application_reviewer.finalized?
      end
    end
    flash[:notice] = "Thank you! Your finalized scores were submitted."
    redirect_to :action => "index"
  end

  protected
  
  def fetch_person
    @person = params[:reviewer] || @current_user.person
  end
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    @layout = @offering.uses_scored_review? ? 'admin' : 'public'
  end

  def fetch_review_committee_member
    unless @offering.review_committee.nil?
      @review_committee_member = @offering.review_committee.members.find_by_person_id(@person)
      raise ExpoException.new("You are not listed as part of the review committee for that award process.") and 
        return if @review_committee_member.nil?
      raise ExpoException.new("You do not have any applications assigned to you to review.") and 
        return if @review_committee_member.applications_for_review.for(@offering).empty?
    end
  end
  
  def fetch_apps
    if @review_committee_member.nil?
      @offering_reviewer = @person.offering_reviewers.find_by_offering_id(@offering)
      @application_reviewers = @offering_reviewer.application_reviewers
      @apps = @offering_reviewer.applications_for_review
    else
      @application_reviewers = @review_committee_member.application_reviewers.for(@offering)
      @apps = @review_committee_member.applications_for_review.for(@offering)
    end
  end

  def fetch_app
    @app = ApplicationForOffering.find(params[:id])
    if !@apps.include?(@app) && @review_committee_member.ok_to_view_past_application?(@app)
      @viewing_past_app = true
    elsif @apps.include? @app
      # ok to proceed
    else
      raise ExpoException.new("You are not allowed to view that application.") and return
    end
  end

  def fetch_application_reviewer
    if @review_committee_member.nil?
      @application_reviewer = @offering_reviewer.application_reviewers.find_by_application_for_offering_id(@app)
    else
      @application_reviewer = @review_committee_member.application_reviewers.find_by_application_for_offering_id(@app)
    end
    if @application_reviewer
      flash[:notice] = "This review has already been finalized. You can view it but cannot submit any changes." if @application_reviewer.finalized?
    end
  end

  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXP-Online", "/expo", {:class => "home"}
    session[:breadcrumbs].add "Reviewer Interface", reviewer_path(@offering)
    session[:breadcrumbs].add @offering.name, reviewer_path(@offering)
  end
  
end
