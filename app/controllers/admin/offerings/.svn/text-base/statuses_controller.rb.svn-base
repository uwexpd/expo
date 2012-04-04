class Admin::Offerings::StatusesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_statuses_breadcrumbs

  def index
    @statuses = @offering.statuses.find(:all, :order => :sequence)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statuses }
    end
  end

  def show
    @status = @offering.statuses.find(params[:id])
    session[:breadcrumbs].add "#{@status.private_title}", offering_status_path(@offering, @status)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @status }
    end
  end

  def new
    @status = @offering.statuses.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @status }
    end
  end

  def edit
    @status = @offering.statuses.find(params[:id])
    session[:breadcrumbs].add "#{@status.private_title}", offering_status_path(@offering, @status)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @status = @offering.statuses.new(params[:status])

    respond_to do |format|
      if @status.save
        flash[:notice] = '@offering.statuses was successfully created.'
        format.html { redirect_to(offering_status_url(@offering, @status)) }
        format.xml  { render :xml => @status, :status => :created, :location => [@offering, @status] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @status = @offering.statuses.find(params[:id])

    respond_to do |format|
      if @status.update_attributes(params[:status])
        flash[:notice] = '@offering.statuses was successfully updated.'
        format.html { redirect_to(offering_status_url(@offering, @status)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @status = @offering.statuses.find(params[:id])
    @status.destroy

    respond_to do |format|
      format.html { redirect_to(offering_statuses_url(@offering)) }
      format.xml  { head :ok }
    end
  end  

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_statuses_breadcrumbs
    session[:breadcrumbs].add "Statuses &amp; Auto E-mails", offering_statuses_path(@offering)
  end
  
end
