class Admin::ServiceLearning::Courses::InstructorsController < Admin::ServiceLearning::CoursesController  
  before_filter :fetch_course, :except => :find_by_uw_netid
  before_filter :courses_instructors_breadcrumbs, :except => :find_by_uw_netid
  
  def index
    @instructors = @service_learning_course.instructors

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @instructors }
    end
  end

  def show
    @instructor = @service_learning_course.instructors.find(params[:id])
    session[:breadcrumbs].add @instructor.fullname rescue "Detail"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @instructor }
    end
  end

  def new
    session[:breadcrumbs].add "New"
    @instructor = @service_learning_course.instructors.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @instructor }
    end
  end

  def edit
    @instructor = @service_learning_course.instructors.find(params[:id])
    session[:breadcrumbs].add @instructor.fullname, service_learning_course_instructor_path(@unit, @quarter, @service_learning_course, @instructor)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @instructor = @service_learning_course.instructors.new(params[:service_learning_course_instructor])

    respond_to do |format|
      if @instructor.save
        flash[:notice] = "#{@instructor.fullname} was successfully added as a course instructor."
        format.html { redirect_to(service_learning_course_instructor_path(@unit, @quarter, @service_learning_course, @instructor)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @instructor = @service_learning_course.instructors.find(params[:id])

    respond_to do |format|
      if @instructor.update_attributes(params[:service_learning_course_instructor])
        flash[:notice] = "#{@instructor.fullname} was successfully updated."
        format.html { redirect_to(service_learning_course_instructor_path(@unit, @quarter, @service_learning_course, @instructor)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @instructor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @instructor = @service_learning_course.instructors.find(params[:id])
    @instructor.destroy

    respond_to do |format|
      format.html { redirect_to(service_learning_course_instructors_url(@unit, @quarter, @service_learning_course)) }
      format.xml  { head :ok }
    end
  end
  
  def find_by_uw_netid
    user = PubcookieUser.authenticate(params[:uw_netid])
    if user
      render :partial => "person_form", :object => user.person
    else
      render :partial => "person_form", :object => Person.new
    end
  end
  
  private

  def fetch_course
    @service_learning_course = ServiceLearningCourse.find(params[:course_id])
    session[:breadcrumbs].add @service_learning_course.title, service_learning_course_path(@unit, @quarter, @service_learning_course)
  end
  
  def courses_instructors_breadcrumbs
    session[:breadcrumbs].add "Instructors", service_learning_course_instructors_path
  end
  
  
end
