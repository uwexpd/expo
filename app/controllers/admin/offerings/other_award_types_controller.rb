class Admin::Offerings::OtherAwardTypesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_other_award_types_breadcrumbs
  
  def index
    @other_award_types = @offering.other_award_types.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @other_award_types }
    end
  end
    
  def show
    @other_award_type = @offering.other_award_types.find(params[:id])
    session[:breadcrumbs].add "#{@other_award_type.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @other_award_type }
    end
  end
  
  def new
    @other_award_type = @offering.other_award_types.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @other_award_type }
    end
  end
  
  def create
    @other_award_type = @offering.other_award_types.new(params[:other_award_type])

    respond_to do |format|
      if @other_award_type.save
        flash[:notice] = "Successfully created other award type."
        format.html { redirect_to offering_other_award_type_path(@offering, @other_award_type) }
        format.xml  { render :xml => @other_award_type, :status => :created, 
                             :location => offering_other_award_type_path(@offering, @other_award_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @other_award_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @other_award_type = @offering.other_award_types.find(params[:id])
    session[:breadcrumbs].add "#{@other_award_type.title}", offering_other_award_type_path(@offering, @other_award_type)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @other_award_type = @offering.other_award_types.find(params[:id])

    respond_to do |format|
      if @other_award_type.update_attributes(params[:other_award_type])
        flash[:notice] = "Successfully updated other award type."
        format.html { redirect_to offering_other_award_type_path(@offering, @other_award_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @other_award_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @other_award_type = @offering.other_award_types.find(params[:id])
    @other_award_type.destroy
    flash[:notice] = "Successfully destroyed other award type."
    respond_to do |format|
      format.html { redirect_to offering_other_award_types_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_other_award_types_breadcrumbs
    session[:breadcrumbs].add "Other Award Types", offering_other_award_types_path(@offering)
  end

end
