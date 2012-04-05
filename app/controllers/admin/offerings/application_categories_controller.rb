class Admin::Offerings::ApplicationCategoriesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_application_categories_breadcrumbs
  
  def index
    @application_categories = @offering.application_categories.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @application_categories }
    end
  end
    
  def show
    @application_category = @offering.application_categories.find(params[:id])
    session[:breadcrumbs].add "#{@application_category.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @application_category }
    end
  end
  
  def new
    @application_category = @offering.application_categories.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @application_category }
    end
  end
  
  def create
    @application_category = @offering.application_categories.new(params[:application_category])

    respond_to do |format|
      if @application_category.save
        flash[:notice] = "Successfully created application category."
        format.html { redirect_to offering_application_category_path(@offering, @application_category) }
        format.xml  { render :xml => @application_category, :status => :created, 
                             :location => offering_application_category_path(@offering, @application_category) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @application_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @application_category = @offering.application_categories.find(params[:id])
    session[:breadcrumbs].add "#{@application_category.title}", offering_application_category_path(@offering, @application_category)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @application_category = @offering.application_categories.find(params[:id])

    respond_to do |format|
      if @application_category.update_attributes(params[:application_category])
        flash[:notice] = "Successfully updated application category."
        format.html { redirect_to offering_application_category_path(@offering, @application_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @application_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @application_category = @offering.application_categories.find(params[:id])
    @application_category.destroy
    flash[:notice] = "Successfully destroyed application category."
    respond_to do |format|
      format.html { redirect_to offering_application_categories_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_application_categories_breadcrumbs
    session[:breadcrumbs].add "Application Categories", offering_application_categories_path(@offering)
  end

end
