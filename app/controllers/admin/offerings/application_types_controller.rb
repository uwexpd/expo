class Admin::Offerings::ApplicationTypesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_application_types_breadcrumbs
  
  def index
    @application_types = @offering.application_types.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @application_types }
    end
  end
    
  def show
    @application_type = @offering.application_types.find(params[:id])
    session[:breadcrumbs].add "#{@application_type.title}"
	
	@new_select_value = { :value => @application_type.id, :title => @application_type.title }
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @application_type }
    end
  end
  
  def new
    @application_type = @offering.application_types.new
    session[:breadcrumbs].add "New"
	
	@application_type.offering_id = params[:offering_id] if params[:offering_id]
	
    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @application_type }
    end
  end
  
  def create
    @application_type = @offering.application_types.new(params[:application_type])

    respond_to do |format|
      if @application_type.save
        flash[:notice] = "Successfully created application type."
        format.html { redirect_to offering_application_type_path(@offering, @application_type) }
        format.xml  { render :xml => @application_type, :status => :created, 
                             :location => offering_application_type_path(@offering, @application_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @application_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @application_type = @offering.application_types.find(params[:id])
    session[:breadcrumbs].add "#{@application_type.title}", offering_application_type_path(@offering, @application_type)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @application_type = @offering.application_types.find(params[:id])

    respond_to do |format|
      if @application_type.update_attributes(params[:application_type])
        flash[:notice] = "Successfully updated application type."
        format.html { redirect_to offering_application_type_path(@offering, @application_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @application_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @application_type = @offering.application_types.find(params[:id])
    @application_type.destroy
    flash[:notice] = "Successfully destroyed application type."
    respond_to do |format|
      format.html { redirect_to offering_application_types_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_application_types_breadcrumbs
    session[:breadcrumbs].add "Application Types", offering_application_types_path(@offering)
  end

end
