class Reviewer::CommitteeController < ReviewerController
  before_filter :add_committee_breadcrumbs
  before_filter :fetch_application_reviewer, :except => [:index]
  
  def index
    @apps = @apps.sort_by(&:fullname)
    render :action => 'index_scored', :layout => @layout if @offering.uses_scored_review?
  end
  
  # Updates the scoring pane to accept scores for the specified app
  def show
    respond_to do |format|
      format.js
    end
  end
  
  def criteria
    redirect_to reviewer_path(:action => :criteria)
  end

  def finalize
    if params[:commit]
      for application_reviewer in @apps.collect{|a| a.reviewers.find_or_create_by_committee_score(true)}
        application_reviewer.update_attribute(:finalized, true) if application_reviewer.started_scoring? && !application_reviewer.finalized?
      end
    end
    flash[:notice] = "Thank you! Your finalized scores were submitted."
    redirect_to :action => "index"
  end

  
  protected
  
  def add_committee_breadcrumbs
    session[:breadcrumbs].add "Committee Decisions", review_committee_path
  end
  
  def fetch_application_reviewer
    @application_reviewer = @app.reviewers.find_or_create_by_committee_score(true)
    @application_reviewer.create_scores
  end
  
end