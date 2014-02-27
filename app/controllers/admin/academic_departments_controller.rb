class Admin::AcademicDepartmentsController < Admin::BaseController

  before_filter :add_academic_departments_breadcrumbs
  
  def index
    @academic_departments = AcademicDepartment.all.sort_by(&:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @academic_departments }
    end
  end
    
  def show
    @academic_department = AcademicDepartment.find(params[:id])
    session[:breadcrumbs].add "#{@academic_department.name}"
	
	@new_select_value = { :value => @academic_department.id, :name => @academic_department.name }
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @academic_department }
    end
  end
  
  def new
    @academic_department = AcademicDepartment.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @academic_department }
    end
  end
  
  def create
    @academic_department = AcademicDepartment.new(params[:academic_department])

    respond_to do |format|
      if @academic_department.save
        flash[:notice] = "Successfully created academic department."
        format.html { redirect_to academic_department_path(@academic_department) }
        format.xml  { render :xml => @academic_department, :status => :created, 
                             :location => academic_department_path(@academic_department) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @academic_department.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @academic_department = AcademicDepartment.find(params[:id])
    session[:breadcrumbs].add "#{@academic_department.name}", academic_department_path(@academic_department)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @academic_department = AcademicDepartment.find(params[:id])

    respond_to do |format|
      if @academic_department.update_attributes(params[:academic_department])
        flash[:notice] = "Successfully updated academic department."
        format.html { redirect_to academic_department_path(@academic_department) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @academic_department.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @academic_department = AcademicDepartment.find(params[:id])
    @academic_department.destroy
    flash[:notice] = "Successfully destroyed academic department."
    respond_to do |format|
      format.html { redirect_to academic_departments_path }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def add_academic_departments_breadcrumbs
    session[:breadcrumbs].add "Academic Departments", academic_departments_path
  end
end