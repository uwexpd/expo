class CommunityPartner::ServiceLearning::StudentsController < CommunityPartner::ServiceLearningController
  before_filter :add_students_breadcrumbs

  def index
    # @placements = @organization_quarter.placements.filled.sort{|x,y| x.person.lastname <=> y.person.lastname}
  end

  def show
    @placement = ServiceLearningPlacement.find(params[:id])
    raise ActiveRecord::RecordNotFound if @placement.organization != @organization
    
    @student = @placement.person
    session[:breadcrumbs].add @student.fullname
  end

  def evaluate
    @placement = ServiceLearningPlacement.find(params[:id])    
    raise ActiveRecord::RecordNotFound if @placement.organization != @organization

    check_if_evaluations_are_allowed
    @evaluation = @placement.evaluation || @placement.create_evaluation    
    
    @is_pipeline = Unit.find(@placement.unit_id).abbreviation == "pipeline" ? true : false
    @tutoring_logs = @placement.tutoring_logs.sort_by(&:log_date) if @is_pipeline
    
    session[:breadcrumbs].add "Submit Evaluation"
  end
  
  def submit_evaluation
    @placement = ServiceLearningPlacement.find(params[:id])
    raise ActiveRecord::RecordNotFound if @placement.organization != @organization
    
    check_if_evaluations_are_allowed
    @evaluation = @placement.evaluation || @placement.create_evaluation

    if @evaluation.submitted?
      flash[:error] = "This evaluation has already been submitted. You cannot resubmit it."
      redirect_to :action => 'index' and return
    end

    if params[:evaluation]
      @evaluation.attributes = params[:evaluation]
      if @evaluation.save && @evaluation.update_attribute(:submitted_at, Time.now)
        @placement.position.organization_quarter.update_finished_evaluation!
        flash[:notice] = "Evaluation received. Thank you!"
        redirect_to :action => 'index' and return
      else
        flash[:error] = "Sorry, but we could not save your responses. Please correct the errors below and try submitting your responses again."
        @show_errors = true
      end
    end
    render :action => 'evaluate'
  end


  protected
  
  def add_students_breadcrumbs
    session[:breadcrumbs].add "Students", community_partner_service_learning_students_path(@quarter)
  end

  def check_if_evaluations_are_allowed
    unless @placement.position.organization_quarter.allow_evals?
      flash[:error] = "You are not allowed to submit evaluations at this time."
      redirect_to :action => "index"
    end
  end

end
