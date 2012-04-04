class Admin::Offerings::Phases::Tasks::ExtraFieldsController < Admin::Offerings::Phases::TasksController

  before_filter :fetch_task
  before_filter :add_extra_fields_breadcrumbs
  
  def index
    @extra_fields = @task.extra_fields.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @extra_fields }
    end
  end

  def show
    @extra_field = @task.extra_fields.find(params[:id])
    session[:breadcrumbs].add "#{@extra_field.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @extra_field }
    end
  end

  def new
    @extra_field = @task.extra_fields.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @extra_field }
    end
  end

  def edit
    @extra_field = @task.extra_fields.find(params[:id])
  end

  def create
    @extra_field = @task.extra_fields.new(params[:extra_field])

    respond_to do |format|
      if @extra_field.save
        flash[:notice] = '@task.extra_fields was successfully created.'
        format.html { redirect_to offering_phase_task_extra_field_url(@offering, @phase, @task, @extra_field) }
        format.xml  { render :xml => @extra_field, :status => :created, :location => @extra_field }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @extra_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @extra_field = @task.extra_fields.find(params[:id])

    respond_to do |format|
      if @extra_field.update_attributes(params[:extra_field])
        flash[:notice] = '@task.extra_fields was successfully updated.'
        format.html { redirect_to offering_phase_task_extra_field_url(@offering, @phase, @task, @extra_field) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @extra_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @extra_field = @task.extra_fields.find(params[:id])
    @extra_field.destroy

    respond_to do |format|
      format.html { redirect_to offering_phase_task_extra_fields_url(@offering, @phase, @task) }
      format.xml  { head :ok }
    end
  end

  protected
  
  def fetch_task
    @task = @phase.tasks.find(params[:task_id])
    session[:breadcrumbs].add "#{@task.title}", offering_phase_task_url(@offering, @phase, @task)
  end
  
  def add_extra_fields_breadcrumbs
    session[:breadcrumbs].add "Extra Fields", offering_phase_task_extra_fields_url(@offering, @phase, @task)
  end
  
end