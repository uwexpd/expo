class Admin::Offerings::RestrictionsController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_restrictions_breadcrumbs
  
  def index
    @restrictions = @offering.restrictions.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @restrictions }
    end
  end
    
  def show
    @restriction = @offering.restrictions.find(params[:id])
    session[:breadcrumbs].add "#{@restriction.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @restriction }
    end
  end
  
  def new
    @restriction = @offering.restrictions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @restriction }
    end
  end
  
  def create
    @restriction = @offering.restrictions.new(params[:restriction])
    @restriction.update_attribute(:type, params[:restriction][:type]) if params[:restriction][:type]

    respond_to do |format|
      if @restriction.save
        flash[:notice] = "Successfully created restriction."
        format.html { redirect_to offering_restriction_path(@offering, @restriction) }
        format.xml  { render :xml => @restriction, :status => :created, 
                             :location => offering_restriction_path(@offering, @restriction) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @restriction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @restriction = @offering.restrictions.find(params[:id])
    session[:breadcrumbs].add "#{@restriction.title}", offering_restriction_path(@offering, @restriction)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @restriction = @offering.restrictions.find(params[:id])
    @restriction.update_attribute(:type, params[:restriction][:type]) if params[:restriction][:type]

    respond_to do |format|
      if @restriction.update_attributes(params[:restriction])
        flash[:notice] = "Successfully updated restriction."
        format.html { redirect_to offering_restriction_path(@offering, @restriction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @restriction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @restriction = @offering.restrictions.find(params[:id])
    @restriction.destroy
    flash[:notice] = "Successfully destroyed restriction."
    respond_to do |format|
      format.html { redirect_to offering_restrictions_url(@offering) }
      format.xml  { head :ok }
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_restrictions_breadcrumbs
    session[:breadcrumbs].add "Restrictions", offering_restrictions_path(@offering)
  end

end
