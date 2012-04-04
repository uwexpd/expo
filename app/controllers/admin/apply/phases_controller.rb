class Admin::Apply::PhasesController < Admin::ApplyController
  skip_before_filter :fetch_apps, :fetch_confirmers

  def index
    @phases = @offering.phases
  end

  def show
    @phase = @offering.phases.find params[:id]
    session[:breadcrumbs].add @phase.name
    
    redirect_to admin_apply_phase_tasks_path(@offering, @phase) unless @phase.show_progress_completion?
    
    @show_sections = []
    @show_sections << [ :in_progress, "Action Needed" ]
    @show_sections << [ :success, "Moving Forward", 'green' ] if @phase.applications_for?(:success)
    @show_sections << [ :failure, "Stopping Here", 'red' ] if @phase.applications_for?(:failure)
    
  end
  
  def mark_complete
    phase = OfferingAdminPhase.find(params[:phase_id])
    phase.complete = true
    phase.save
    render :partial => "admin/apply/phase", :object => phase
  end
  
  def mark_incomplete
    phase = OfferingAdminPhase.find(params[:phase_id])
    phase.complete = false
    phase.save
    render :partial => "admin/apply/phase", :object => phase
  end

  def complete
    @phase = OfferingAdminPhase.find params[:id]
    @phase.update_attribute :complete, true
    @offering.current_offering_admin_phase = @phase.next
    @offering.save
    redirect_to :action => "show", :id => @phase.next
  end
  
  def switch_to
    @phase = OfferingAdminPhase.find params[:id]
    @offering.current_offering_admin_phase = @phase
    @offering.save
    redirect_to :action => "show", :id => @phase
  end

  protected
  
  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add @offering.title, admin_apply_path(@offering)
  end

end