class Admin::StudentsController < Admin::BaseController
  before_filter :add_to_breadcrumbs

  require_role :transcript_viewer, :only => :transcript
  
  skip_before_filter :add_to_session_history, :only => [:photo]

  def index
    session[:breadcrumbs].add "All Students in EXPo"
    # @students = Student.paginate :order => 'lastname ASC, firstname ASC', :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @students }
    end
  end
  
  def show
    system_key = params[:student][:system_key] if params[:student]
    system_key = params[:id] if params[:lookup_by_system_key]
    @student = case
    when !system_key.nil? && !system_key.blank? && system_key.to_i != 0
      Student.find_or_create_by_system_key(system_key)
    when !system_key.nil? && system_key != "0"
      StudentRecord.find_by_anything(system_key, 100)
    when params[:student_search]
      StudentRecord.find_by_anything(params[:search], 100)
    when params[:id]
      Student.find_by_id(params[:id])
    when params[:search]
      StudentRecord.find_by_anything(params[:search])
    end      
    if @student.nil? || (@student.is_a?(Array) && @student.empty?)
      flash[:error] = "Sorry, but we couldn't find a student record that matched your criteria."
      return redirect_to :action => "index"
    elsif @student.is_a?(Array) && @student.size > 1
      return redirect_to :action => "search", :params => { :search => (params[:search].blank? ? params[:student_search] : params[:search]) }
    end
    @student = @student.flatten.first if @student.is_a?(Array)
    @student = @student.student if @student.is_a?(StudentRecord)
    session[:breadcrumbs].add @student.fullname

    if params['tab']
      render :partial => "admin/students/tabs/#{params[:tab]}", :locals => { :admin_view => true } and return
    end
  end

  def search
    @results = StudentRecord.find_by_anything(params[:search]) if params[:search]
    session[:breadcrumbs].add "Search"
  end

  def transcript
    @student = Student.find_by_id(params[:id])
    session[:breadcrumbs].add @student.fullname
  end
  
  def note
    @student = Student.find_by_id(params[:id])
    @note = @student.notes.create(params[:note])
    
    respond_to do |format|
      format.html { redirect_to admin_student_path(@student) }
      format.js
    end    
  end

  def photo
    begin
      student_photo = StudentPhoto.find(params[:reg_id])
      file_path = student_photo.try(:image_path, params[:size])
      if file_path
        send_file file_path, :disposition => 'inline', :type => 'image/jpeg' # TODO :x_sendfile => true in production
      else
        send_default_photo(params[:size])
      end
    rescue ActiveResource::ResourceNotFound
      send_default_photo(params[:size])
    end
  end

  def auto_complete_for_student_anything
    @students = StudentRecord.find_by_anything(params[:student_search], 10)
    partial_name = params[:show] == 'table_row' ? "auto_complete_table" : "auto_complete"
    render :partial => partial_name, :object => @students, :locals => { :highlight_phrase => params[:student_search] }    
  end
  
  def get_pipeline_positions
    @student = Student.find_by_id(params[:student_id])
    @quarter = Quarter.find(params[:quarter_id])
    
    respond_to do |format|
      format.js
    end 
  end
  
  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Students", :action => 'index'
  end

  def send_default_photo(size)
    send_file File.join(RAILS_ROOT, "public", "images", "app", "blank_avatar.png"), 
              :disposition => 'inline', :type => 'image/png', :status => 404
  end
  
end
