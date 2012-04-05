class Admin::Offerings::PhasesController < Admin::OfferingsController
  
  before_filter :fetch_offering
  before_filter :add_phases_breadcrumbs
  
  def index
    @phases = @offering.phases.all.sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phases }
    end
  end

  def show
    @phase = @offering.phases.find(params[:id])
    session[:breadcrumbs].add @phase.name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phase }
    end
  end

  def new
    @phase = @offering.phases.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phase }
    end
  end

  def edit
    @phase = @offering.phases.find(params[:id])
    session[:breadcrumbs].add @phase.name
  end

  def create
    @phase = @offering.phases.new(params[:phase])

    respond_to do |format|
      if @phase.save
        flash[:notice] = "#{@phase.name} was successfully created."
        format.html { redirect_to offering_phase_url(@offering, @phase) }
        format.xml  { render :xml => @phase, :status => :created, :location => @phase }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phase.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @phase = @offering.phases.find(params[:id])

    respond_to do |format|
      if @phase.update_attributes(params[:phase])
        flash[:notice] = "#{@phase.name} was successfully updated."
        format.html { redirect_to(offering_phase_url(@offering, @phase)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phase.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @phase = @offering.phases.find(params[:id])
    @phase.destroy
    flash[:notice] = "#{@phase.name} was deleted."
        
    respond_to do |format|
      format.html { redirect_to offering_phases_url(@offering) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_url(@offering)
  end
  
  def add_phases_breadcrumbs
    session[:breadcrumbs].add "Phases", offering_phases_url(@offering)
  end
  
end
