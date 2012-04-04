class Admin::ServiceLearning::ExtraEnrolleesController < Admin::ServiceLearningController

  # POST /admin/service_learning_extra_enrollees
  # POST /admin/service_learning_extra_enrollees.xml
  def create
    # @extra_enrollee = CourseExtraEnrollee.new()
    # @extra_enrollee.person_id = Student.find_by_anything(params[:extra_enrollee][:student_anything]).first.id rescue nil
    # @service_learning_course = ServiceLearningCourse.find(params[:course_id]) rescue nil

    respond_to do |format|
      if @extra_enrollee.save
        flash[:notice] = 'Admin::ServiceLearning::ExtraEnrollee was successfully created.'
        format.html { redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course)) }
        format.xml  { render :xml => @extra_enrollee, :status => :created, :location => @extra_enrollee }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @extra_enrollee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # This method actually creates a new course_extra_enrollee. TODO: Move this to the proper method.
  def update
    @service_learning_course = ServiceLearningCourse.find(params[:course_id]) rescue nil
    @student_to_add = Student.find_by_anything(params[:extra_enrollee][:student_anything]) rescue nil
    @student_to_add = @student_to_add.first if @student_to_add.is_a?(Array)
    if @student_to_add.nil?
      flash[:error] = "Could not find a matching student. Please try again."
      redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course)) and return
    end
    
    if params[:extra_enrollee][:course].blank? # Add this student as At Large
      @extra_enrollee = ServiceLearningCourseExtraEnrollee.new()
      @extra_enrollee.person_id = @student_to_add.id
      @extra_enrollee.service_learning_course_id = @service_learning_course.id
      if @service_learning_course.enrollees.include? @student_to_add
        flash[:error] = "#{@student_to_add.fullname} is already enrolled in this course."
        redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course)) and return
      end
    else
      @extra_enrollee = CourseExtraEnrollee.new()
      @course_to_add = @service_learning_course.courses.find(params[:extra_enrollee][:course])
      if @course_to_add.course.all_enrollees.include? @student_to_add
        flash[:error] = "#{@student_to_add.fullname} is already enrolled in this course."
        redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course)) and return
      end
      @extra_enrollee.person_id = @student_to_add.id
      @extra_enrollee.ts_year = @course_to_add.ts_year
      @extra_enrollee.ts_quarter = @course_to_add.ts_quarter
      @extra_enrollee.course_branch = @course_to_add.course_branch
      @extra_enrollee.course_no = @course_to_add.course_no
      @extra_enrollee.dept_abbrev = @course_to_add.dept_abbrev
      @extra_enrollee.section_id = @course_to_add.section_id
    end

    if @extra_enrollee.save
      flash[:notice] = "Added #{@extra_enrollee.person.fullname} to course."
      redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course))
    else
      flash[:error] = "Could not find a matching student. Please try again."
      redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course))
    end
  end
  

  # DELETE /admin/service_learning_extra_enrollees/1
  # DELETE /admin/service_learning_extra_enrollees/1.xml
  def destroy
    @extra_enrollee = params[:type]=="course" ? @extra_enrollee = CourseExtraEnrollee.find(params[:id]) : ServiceLearningCourseExtraEnrollee.find(params[:id])           
    @extra_enrollee.destroy
    @service_learning_course = ServiceLearningCourse.find(params[:course_id])

    flash[:notice] = "Successfully dropped #{@extra_enrollee.person.fullname} from #{@service_learning_course.title} class roster."
    respond_to do |format|
      format.html { redirect_to(students_service_learning_course_path(@unit, @quarter, @service_learning_course)) }
      format.xml  { head :ok }
    end
  end
end
