class Admin::HelpTextsController < Admin::BaseController
  before_filter :help_text_breadcrumbs

  uses_tiny_mce
  
  def index
    @models = Population.model_names.sort
  end
  
  def model
    @model = params[:model]
    @attributes = @model.constantize.first.attributes.sort
    @help_texts = HelpText.find_all_by_object_type_and_attribute_name(@model, nil)
    session[:breadcrumbs].add "#{@model}", :model => @model
  end
  
  def update_model
    @model = params[:model]
    for attribute_name, values in params[:help_text]
      ModelHelpText.set(@model, attribute_name, values)
    end
    respond_to do |format|
      format.html { redirect_to :action => "model", :model => @model }
      format.js 
    end
  end

  def new
    @help_text = params[:model] ? HelpText.new(:object_type => params[:model].to_s) : HelpText.new
    session[:breadcrumbs].add "#{params[:model].to_s}", :action => 'model', :model => params[:model] if params[:model]
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @help_text }
    end
  end

  def edit
    @help_text = HelpText.find(params[:id])
    session[:breadcrumbs].add "#{@help_text.title}", @help_text
    session[:breadcrumbs].add "Edit"
  end
  
  def create
    @help_text = HelpText.new(params[:help_text])

    respond_to do |format|
      if @help_text.save
        flash[:notice] = "HelpText was successfully created."
        format.html { redirect_to(params[:model] ? {:action => 'model', :model => params[:model]} : {:action => 'index'}) }
        format.xml  { render :xml => @help_text, :status => :created, :location => @help_text }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @help_text.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @help_text = HelpText.find(params[:id])

    respond_to do |format|
      if @help_text.update_attributes(params[:help_text])
        flash[:notice] = "HelpText was successfully updated."
        format.html { redirect_to(@help_text) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @help_text.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @help_text = HelpText.find(params[:id])
    @help_text.destroy

    respond_to do |format|
      format.html { redirect_to(admin_help_texts_url) }
      format.xml  { head :ok }
    end
  end
    
  private
  
  def help_text_breadcrumbs
    session[:breadcrumbs].add "Help Text", :action => 'index'
  end
  
end
