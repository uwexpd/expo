class Admin::Offerings::MentorTypesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_mentor_types_breadcrumbs
  
  def index
    @mentor_types = @offering.mentor_types.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentor_types }
    end
  end
    
  def show
    @mentor_type = @offering.mentor_types.find(params[:id])
    session[:breadcrumbs].add "#{@mentor_type.id}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor_type }
    end
  end
  
  def new
    @mentor_type = @offering.mentor_types.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mentor_type }
    end
  end
  
  def create
    @mentor_type = @offering.mentor_types.new(params[:mentor_type])

    respond_to do |format|
      if @mentor_type.save
        flash[:notice] = "Successfully created mentor type."
        format.html { redirect_to offering_mentor_type_path(@offering, @mentor_type) }
        format.xml  { render :xml => @mentor_type, :status => :created, 
                             :location => offering_mentor_type_path(@offering, @mentor_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mentor_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @mentor_type = @offering.mentor_types.find(params[:id])
    session[:breadcrumbs].add "#{@mentor_type.id}", offering_mentor_type_path(@offering, @mentor_type)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @mentor_type = @offering.mentor_types.find(params[:id])

    respond_to do |format|
      if @mentor_type.update_attributes(params[:mentor_type])
        flash[:notice] = "Successfully updated mentor type."
        format.html { redirect_to offering_mentor_type_path(@offering, @mentor_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mentor_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @mentor_type = @offering.mentor_types.find(params[:id])
    @mentor_type.destroy
    flash[:notice] = "Successfully destroyed mentor type."
    respond_to do |format|
      format.html { redirect_to offering_mentor_types_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_mentor_types_breadcrumbs
    session[:breadcrumbs].add "Mentor Types", offering_mentor_types_path(@offering)
  end

end
