class Admin::Offerings::Pages::Questions::OptionsController < Admin::Offerings::Pages::QuestionsController

  before_filter :fetch_question
  
  def index
    @option = @question.options

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @option }
    end
  end

  # def show
  #   @option = @question.options.find(params[:id])
  #   session[:breadcrumbs].add "#{@option.type}"
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @option }
  #   end
  # end

  def new
    @option = @question.options.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @option }
    end
  end

  def edit
    @option = @question.options.find(params[:id])
    session[:breadcrumbs].add "#{@option.type}", offering_page_question_option_path(@offering, @page, @question, @option)
    session[:breadcrumbs].add "Edit"
  end

  def create
    klass = params[:option][:type] || "OfferingQuestionOption"
    @option = klass.constantize.new(params[:option])
    @option.offering_question = @question

    respond_to do |format|
      if @option.save
        flash[:notice] = "Option was successfully created."
        format.html { redirect_to edit_offering_page_question_path(@offering, @page, @question, :anchor => 'options') }
        format.xml  { render :xml => @option, :status => :created, :location => @option }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @option.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @option = @question.options.find(params[:id])

    respond_to do |format|
      if @option.update_attributes(params[:option])
        flash[:notice] = "Option was successfully updated."
        format.html { redirect_to edit_offering_page_question_path(@offering, @page, @question, :anchor => 'options') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @option.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @option = @question.options.find(params[:id])
    @option.destroy

    respond_to do |format|
      format.html { redirect_to edit_offering_page_question_path(@offering, @page, @question, :anchor => 'options') }
      format.xml  { head :ok }
      format.js
    end
  end
  
  protected
  
  def fetch_question
    @question = @page.questions.find params[:question_id]
  end
  
end