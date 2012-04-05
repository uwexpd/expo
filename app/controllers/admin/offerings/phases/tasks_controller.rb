class Admin::Offerings::Phases::TasksController < Admin::Offerings::PhasesController

  before_filter :fetch_phase
  before_filter :add_tasks_breadcrumbs
  
  def index
    @tasks = @phase.tasks.find :all, :order => :sequence

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  def show
    @task = @phase.tasks.find(params[:id])
    session[:breadcrumbs].add "#{@task.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  def new
    @task = @phase.tasks.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  def edit
    @task = @phase.tasks.find(params[:id])
    session[:breadcrumbs].add "#{@task.title}", offering_phase_task_url(@offering, @phase, @task)
    session[:breadcrumbs].add "Edit"
    
  end

  def create
    @task = @phase.tasks.new(params[:task])
    update_caches = @task.update_task_completion_status_caches_after_save

    respond_to do |format|
      if @task.save
        @task.update_task_completion_status_caches! if update_caches
        flash[:notice] = '@phase.tasks was successfully created.'
        format.html { redirect_to(offering_phase_task_url(@offering, @phase, @task)) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @task = @phase.tasks.find(params[:id])
    @task.attributes = params[:task]

    update_caches = @task.update_task_completion_status_caches_after_save
    # update_caches = false unless @task.changes.include?("completion_criteria") || @task.changes.include?("context")

    respond_to do |format|
      if @task.save
        @task.update_task_completion_status_caches! if update_caches
        flash[:notice] = "#{@task.title} was successfully updated#{" and completion status caches have been refreshed" if update_caches}."
        format.html { redirect_to(offering_phase_task_url(@offering, @phase, @task)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @task = @phase.tasks.find(params[:id])
    @task.destroy
    flash[:notice] = "#{@task.title} was deleted."

    respond_to do |format|
      format.html { redirect_to(offering_phase_tasks_url(@offering, @phase)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_phase
    @phase = @offering.phases.find(params[:phase_id])
    session[:breadcrumbs].add "#{@phase.name}", offering_phase_url(@offering, @phase)
  end
  
  def add_tasks_breadcrumbs
    session[:breadcrumbs].add "Tasks", offering_phase_tasks_url(@offering, @phase)
  end
  
end