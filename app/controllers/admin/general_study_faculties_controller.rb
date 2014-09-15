class Admin::GeneralStudyFacultiesController < Admin::BaseController

  before_filter :add_general_study_faculties_breadcrumbs
  
  def index
    @general_study_faculties = GeneralStudyFaculty.paginate :order => 'lastname ASC, firstname ASC', :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @general_study_faculties }
    end
  end
    
  def show
    @general_study_faculty = GeneralStudyFaculty.find(params[:id])
    session[:breadcrumbs].add "#{@general_study_faculty.firstname} #{@general_study_faculty.lastname}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @general_study_faculty }
    end
  end
  
  def new
    @general_study_faculty = GeneralStudyFaculty.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @general_study_faculty }
    end
  end
  
  def create
    @general_study_faculty = GeneralStudyFaculty.new(params[:general_study_faculty])

    respond_to do |format|
      if @general_study_faculty.save
        flash[:notice] = "Successfully created a faculty for general study."
        format.html { redirect_to general_study_faculty_path(@general_study_faculty) }
        format.xml  { render :xml => @general_study_faculty, :status => :created, 
                             :location => general_study_faculty_path(@general_study_faculty) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @general_study_faculty.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @general_study_faculty = GeneralStudyFaculty.find(params[:id])
    session[:breadcrumbs].add "#{@general_study_faculty.firstname} #{@general_study_faculty.lastname}", general_study_faculty_path(@general_study_faculty)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @general_study_faculty = GeneralStudyFaculty.find(params[:id])

    respond_to do |format|
      if @general_study_faculty.update_attributes(params[:general_study_faculty])
        flash[:notice] = "Successfully updated this general study faculty."
        format.html { redirect_to general_study_faculty_path(@general_study_faculty) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @general_study_faculty.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @general_study_faculty = GeneralStudyFaculty.find(params[:id])
    @general_study_faculty.destroy
    flash[:notice] = "Successfully deleted this general study faculty."
    respond_to do |format|
      format.html { redirect_to general_study_faculties_path }
      format.xml  { head :ok }
      format.js
    end
  end
  
  def search
    session[:breadcrumbs].add "Search"
    @general_study_faculties = GeneralStudyFaculty.find(:all, :conditions => ["lastname LIKE ?", "%#{params[:search][:lastname]}%"]) unless params[:search][:lastname].blank?
    @general_study_faculties = GeneralStudyFaculty.find(:all, :conditions => ['uw_netid = ?', params[:search][:uw_netid]]) unless params[:search][:uw_netid].blank?
    
    if @general_study_faculties.empty?
      flash[:error] = "Can not find the faculty with your search input."
      redirect_to :action => "index" and return
    end
    @general_study_faculties = @general_study_faculties.paginate(:page => params[:page], :per_page => 25)
    render :action => "index"
  end

  protected

  def add_general_study_faculties_breadcrumbs
    session[:breadcrumbs].add "General Study Faculties", general_study_faculties_path
  end



end