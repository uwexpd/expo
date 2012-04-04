class Admin::Offerings::LocationSectionsController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_location_sections_breadcrumbs
  
  def index
    @location_sections = @offering.location_sections.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @location_sections }
    end
  end
    
  def show
    @location_section = @offering.location_sections.find(params[:id])
    session[:breadcrumbs].add "#{@location_section.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location_section }
    end
  end
  
  def new
    @location_section = @offering.location_sections.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location_section }
    end
  end
  
  def create
    @location_section = @offering.location_sections.new(params[:location_section])

    respond_to do |format|
      if @location_section.save
        flash[:notice] = "Successfully created location section."
        format.html { redirect_to offering_location_section_path(@offering, @location_section) }
        format.xml  { render :xml => @location_section, :status => :created, 
                             :location => offering_location_section_path(@offering, @location_section) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location_section.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @location_section = @offering.location_sections.find(params[:id])
    session[:breadcrumbs].add "#{@location_section.title}", offering_location_section_path(@offering, @location_section)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @location_section = @offering.location_sections.find(params[:id])

    respond_to do |format|
      if @location_section.update_attributes(params[:location_section])
        flash[:notice] = "Successfully updated location section."
        format.html { redirect_to offering_location_section_path(@offering, @location_section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location_section.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @location_section = @offering.location_sections.find(params[:id])
    @location_section.destroy
    flash[:notice] = "Successfully destroyed location section."
    respond_to do |format|
      format.html { redirect_to offering_location_sections_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_location_sections_breadcrumbs
    session[:breadcrumbs].add "Location Sections", offering_location_sections_path(@offering)
  end

end
