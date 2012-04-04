class Admin::Apply::Phases::TasksController < Admin::Apply::PhasesController
  before_filter :fetch_phase
  
  def index
    @tasks = @phase.tasks
  end
  
  def show
    @task = @phase.tasks.find(params[:id])
    session[:breadcrumbs].add "#{@phase.name}", admin_apply_phase_path(@offering, @phase)
    session[:breadcrumbs].add @task.title
  end
  
  def new
    
  end
  
  def create
    @phase = OfferingAdminPhase.find params[:id]
    if params[:new_phase_task]
      new_task = @phase.tasks.create params[:new_phase_task]
      flash[:notice] = "Added task '#{new_task.title}'."
    end
    redirect_to :action => "phase", :id => @phase
  end
    
  def destroy
    @phase = OfferingAdminPhase.find params[:id]
    if params[:task_id]
      removed_task = @phase.tasks.find(params[:task_id]).destroy
      flash[:notice] = "Removed task '#{removed_task.title}'."
    end
    redirect_to :action => "phase", :id => @phase
  end
  
  def complete
    @task = @phase.tasks.find(params[:id])
    @task.update_attribute(:complete, true)
    respond_to do |format|
      format.html { redirect_to :action => "show", :id => @task }
      format.js
    end    
  end
  
  def uncomplete
    @task = @phase.tasks.find(params[:id])
    @task.update_attribute(:complete, false)
    respond_to do |format|
      format.html { redirect_to :action => "show", :id => @task }
      format.js
    end        
  end
  
  def refresh_task_completion_statuses
    @task = @phase.tasks.find(params[:id])
    @task.update_task_completion_status_caches!
    flash[:notice] = "Successfully refreshed task completion statuses for task \"#{@task.title}.\""
    redirect_to :back
  end
  
  def sort
    params[:tasks].each_with_index do |id, index|
      @phase.tasks.update_all(['sequence=?', index+1], ['id=?', id])
    end
    respond_to do |format|
      format.js
    end
  end
  
  def mass_update
    if params[:tasks]
      params[:tasks].each do |task,values|
        @phase.tasks.find(task).update_attributes(values)
      end
    end
    respond_to do |format|
      format.js { render :partial => "sidebar_task", :collection => @phase.tasks }
    end
  end
  
  protected
  
  def fetch_phase
    @phase = @offering.phases.find(params[:phase_id])
  end
  
end