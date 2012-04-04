class Admin::Offerings::MentorQuestionsController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_mentor_questions_breadcrumbs
  
  def index
    @mentor_questions = @offering.mentor_questions.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentor_questions }
    end
  end
    
  def show
    @mentor_questions = @offering.mentor_questions.find(params[:id])
    session[:breadcrumbs].add "#{@mentor_questions.question}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor_questions }
    end
  end
  
  def new
    @mentor_questions = @offering.mentor_questions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mentor_questions }
    end
  end
  
  def create
    @mentor_questions = @offering.mentor_questions.new(params[:mentor_questions])

    respond_to do |format|
      if @mentor_questions.save
        flash[:notice] = "Successfully created mentor questions."
        format.html { redirect_to offering_mentor_question_path(@offering, @mentor_questions) }
        format.xml  { render :xml => @mentor_questions, :status => :created, 
                             :location => offering_mentor_question_path(@offering, @mentor_questions) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mentor_questions.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @mentor_questions = @offering.mentor_questions.find(params[:id])
    session[:breadcrumbs].add "#{@mentor_questions.question}", offering_mentor_question_path(@offering, @mentor_questions)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @mentor_questions = @offering.mentor_questions.find(params[:id])

    respond_to do |format|
      if @mentor_questions.update_attributes(params[:mentor_questions])
        flash[:notice] = "Successfully updated mentor questions."
        format.html { redirect_to offering_mentor_question_path(@offering, @mentor_questions) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mentor_questions.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @mentor_questions = @offering.mentor_questions.find(params[:id])
    @mentor_questions.destroy
    flash[:notice] = "Successfully destroyed mentor questions."
    respond_to do |format|
      format.html { redirect_to offering_mentor_questions_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_mentor_questions_breadcrumbs
    session[:breadcrumbs].add "Mentor Questions", offering_mentor_questions_path(@offering)
  end

end
