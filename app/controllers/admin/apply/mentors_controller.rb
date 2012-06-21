class Admin::Apply::MentorsController < Admin::ApplyController
  before_filter :fetch_offering_for_mentor
  before_filter :fetch_app
  before_filter :add_mentor_breadcrumbs
  skip_before_filter :fetch_apps
  skip_before_filter :fetch_confirmers

  def auto_complete_model_for_person_fullname
    @result = Person.non_student.find_all{|p| p.fullname.downcase.include?(params[:person][:fullname].downcase)}[0..10]
    render :partial => "auto_complete", :object => @result, :locals => { :highlight_phrase => params[:person][:fullname] }
  end
  
  def index
    @mentors = @app.mentors.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentors }
    end
  end

  def show
    @mentor = @app.mentors.find(params[:id])
    session[:breadcrumbs].add "#{@mentor.fullname}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor }
    end
  end

  def new
    @mentor = @app.mentors.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mentor }
    end
  end

  def edit
    @mentor = @app.mentors.find(params[:id])
    session[:breadcrumbs].add "#{@mentor.fullname}", admin_apply_mentor_path(@offering, @app, @mentor)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @mentor = @app.mentors.new(params[:mentor])

    respond_to do |format|
      if @mentor.save
        flash[:notice] = "@app.mentors was successfully created."
        format.html { redirect_to(redirect_to_path || admin_apply_mentor_path(@offering, @app, @mentor)) }
        format.xml  { render :xml => @mentor, :status => :created, :location => admin_apply_mentor_path(@offering, @app, @mentor) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mentor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @mentor = @app.mentors.find(params[:id])    
    
    respond_to do |format|
      if @mentor.update_attributes(params[:mentor])
        flash[:notice] = "@app.mentors was successfully updated."
        format.html { redirect_to(redirect_to_path || admin_apply_mentor_path(@offering, @app, @mentor)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mentor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @mentor = @app.mentors.find(params[:id])
    @mentor.destroy

    respond_to do |format|
      format.html { redirect_to(redirect_to_path || admin_apply_mentors_path(@offering, @app)) }
      format.xml  { head :ok }
    end
  end
  
  protected

  def fetch_offering_for_mentor
    @offering = Offering.find params[:offering]
    session[:breadcrumbs].add "#{@offering.title}", admin_apply_path(@offering)
  end
  
  def fetch_app
    @app = @offering.application_for_offerings.find params[:application_id]
    session[:breadcrumbs].add "#{@app.lastname_first}", admin_app_url(@offering, @app, :anchor => 'mentor_letter')
  end

  def add_mentor_breadcrumbs
    session[:breadcrumbs].add "Mentors", admin_apply_mentors_url(@offering, @app)
  end
  
end