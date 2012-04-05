class Admin::Offerings::Pages::Questions::ValidationsController < Admin::Offerings::Pages::QuestionsController

  before_filter :fetch_question
  
  def index
    @validation = @question.validations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @validation }
    end
  end

  # def show
  #   @validation = @question.validations.find(params[:id])
  #   session[:breadcrumbs].add "#{@validation.type}"
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @validation }
  #   end
  # end

  def new
    @validation = @question.validations.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @validation }
    end
  end

  def edit
    @validation = @question.validations.find(params[:id])
    session[:breadcrumbs].add "#{@validation.type}", offering_page_question_validation_path(@offering, @page, @question, @validation)
    session[:breadcrumbs].add "Edit"
  end

  def create
    klass = params[:validation][:type] || "OfferingQuestionValidation"
    @validation = klass.constantize.new(params[:validation])
    @validation.offering_question = @question

    respond_to do |format|
      if @validation.save
        flash[:notice] = "Validation was successfully created."
        format.html { redirect_to edit_offering_page_question_path(@offering, @page, @question, :anchor => 'validation') }
        format.xml  { render :xml => @validation, :status => :created, :location => @validation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @validation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @validation = @question.validations.find(params[:id])

    respond_to do |format|
      if @validation.update_attributes(params[:validation])
        flash[:notice] = "Validation was successfully updated."
        format.html { redirect_to edit_offering_page_question_path(@offering, @page, @question, :anchor => 'validation') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @validation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @validation = @question.validations.find(params[:id])
    @validation.destroy

    respond_to do |format|
      format.html { redirect_to edit_offering_page_question_path(@offering, @page, @question, :anchor => 'validation') }
      format.xml  { head :ok }
      format.js
    end
  end
  
  protected
  
  def fetch_question
    @question = @page.questions.find params[:question_id]
  end
  
end