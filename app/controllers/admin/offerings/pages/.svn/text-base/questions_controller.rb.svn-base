class Admin::Offerings::Pages::QuestionsController < Admin::Offerings::PagesController
  
  before_filter :fetch_page
  before_filter :add_questions_breadcrumbs

  helper :apply
  
  # GET /offerings/pages_questions
  # GET /offerings/pages_questions.xml
  def index
    @questions = @page.questions.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /offerings/pages_questions/1
  # GET /offerings/pages_questions/1.xml
  def show
    @question = @page.questions.find(params[:id])
    session[:breadcrumbs].add "#{@question.short_title}"

    initialize_fake_app_for_preview

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /offerings/pages_questions/new
  # GET /offerings/pages_questions/new.xml
  def new
    @question = @page.questions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /offerings/pages_questions/1/edit
  def edit
    @question = @page.questions.find(params[:id])
    session[:breadcrumbs].add "Edit"
  end

  # POST /offerings/pages_questions
  # POST /offerings/pages_questions.xml
  def create
    @question = @page.questions.new(params[:question])

    respond_to do |format|
      if @question.save
        flash[:notice] = 'Your question was successfully created. Now you can fill in additional details.'
        format.html { redirect_to edit_offering_page_question_url(@offering, @page, @question, :anchor => 'validation') }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /offerings/pages_questions/1
  # PUT /offerings/pages_questions/1.xml
  def update
    @question = @page.questions.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = 'Your question was successfully updated.'
        format.html { redirect_to(offering_page_question_url(@offering, @page, @question)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /offerings/pages_questions/1
  # DELETE /offerings/pages_questions/1.xml
  def destroy
    @question = @page.questions.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(offering_page_questions_url(@offering, @page)) }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:questions].each_with_index do |id, index|
      @page.questions.update_all(['ordering=?', index+1], ['id=?', id])
    end
    respond_to do |format|
      format.js   { render :text => "OK", :status => 200 }
    end
  end
  
  def preview
    @question = @page.questions.find(params[:id])
    @question.attributes = params[:question]

    initialize_fake_app_for_preview
    
    respond_to do |format|
      format.js { render :partial => 'admin/offerings/pages/questions/tabs/preview' }
    end
    
  end
  
  protected
  
  def fetch_page
    @page = @offering.pages.find params[:page_id]
    session[:breadcrumbs].add "#{@page.title}", offering_page_path(@offering, @page)
  end
  
  def add_questions_breadcrumbs
    session[:breadcrumbs].add "Questions", offering_page_questions_path(@offering, @page)
  end
  
  def initialize_fake_app_for_preview
    @application_page = ApplicationPage.new(:offering_page_id => @page.id)
    @student_user = User.find_by_login_and_identity_type(@current_user.login, "Student")
    if @student_user
      @user_application = ApplicationForOffering.new
      @user_application.person_id = @student_user.person_id
    end
  end
  
end
