class Admin::Offerings::DashboardItemsController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_dashboard_item_breadcrumbs

  def index
    @enabled_dashboard_items = @offering.dashboard_items.enabled.sort
    @disabled_dashboard_items = @offering.dashboard_items.disabled.sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dashboard_items }
    end
  end

  def show
    @dashboard_item = @offering.dashboard_items.find(params[:id])
    session[:breadcrumbs].add "#{@dashboard_item.title}", offering_dashboard_item_path(@offering, @dashboard_item)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dashboard_item }
    end
  end

  def new
    @dashboard_item = @offering.dashboard_items.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dashboard_item }
    end
  end

  def edit
    @dashboard_item = @offering.dashboard_items.find(params[:id])
    session[:breadcrumbs].add "#{@dashboard_item.title}", offering_dashboard_item_path(@offering, @dashboard_item)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @dashboard_item = @offering.dashboard_items.new(params[:dashboard_item])

    respond_to do |format|
      if @dashboard_item.save
        flash[:notice] = 'Dashboard item was successfully created.'
        format.html { redirect_to(offering_dashboard_item_url(@offering, @dashboard_item)) }
        format.xml  { render :xml => @dashboard_item, :dashboard_item => :created, :location => [@offering, @dashboard_item] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dashboard_item.errors, :dashboard_item => :unprocessable_entity }
      end
    end
  end

  def update
    @dashboard_item = @offering.dashboard_items.find(params[:id])

    respond_to do |format|
      if @dashboard_item.update_attributes(params[:dashboard_item])
        flash[:notice] = 'Dashboard item was successfully updated.'
        format.html { redirect_to(offering_dashboard_item_url(@offering, @dashboard_item)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dashboard_item.errors, :dashboard_item => :unprocessable_entity }
      end
    end
  end

  def destroy
    @dashboard_item = @offering.dashboard_items.find(params[:id])
    @dashboard_item.destroy

    respond_to do |format|
      format.html { redirect_to(offering_dashboard_items_url(@offering)) }
      format.xml  { head :ok }
    end
  end  

  def disable
    @dashboard_item = @offering.dashboard_items.find(params[:id])
    @dashboard_item.update_attribute(:disabled, true)
    redirect_to :action => "index"
  end

  def enable
    @dashboard_item = @offering.dashboard_items.find(params[:id])
    @dashboard_item.update_attribute(:disabled, false)
    redirect_to :action => "index"
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_dashboard_item_breadcrumbs
    session[:breadcrumbs].add "Dashboard Items", offering_dashboard_items_path(@offering)
  end
  
end
