class Admin::Offerings::Restrictions::ExemptionsController < Admin::Offerings::RestrictionsController

  before_filter :fetch_restriction
  before_filter :add_exemptions_breadcrumbs
  
  def index
    @exemptions = @restriction.exemptions.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exemptions }
    end
  end
    
  def show
    @exemption = @restriction.exemptions.find(params[:id])
    session[:breadcrumbs].add "#{@exemption.id}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exemption }
    end
  end
  
  def new
    @exemption = @restriction.exemptions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exemption }
    end
  end
  
  def create
    @exemption = @restriction.exemptions.new(params[:exemption])

    respond_to do |format|
      if @exemption.save
        flash[:notice] = "Successfully created exemption."
        format.html { redirect_to offering_restriction_exemptions_path(@offering, @restriction) }
        format.xml  { render :xml => @exemption, :status => :created, 
                             :location => offering_restriction_exemptions_path(@offering, @restriction) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exemption.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @exemption = @restriction.exemptions.find(params[:id])
    session[:breadcrumbs].add "#{@exemption.id}", offering_restriction_exemptions_path(@offering, @restriction)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @exemption = @restriction.exemptions.find(params[:id])

    respond_to do |format|
      if @exemption.update_attributes(params[:exemption])
        flash[:notice] = "Successfully updated exemption."
        format.html { redirect_to offering_restriction_exemptions_path(@offering, @restriction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exemption.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @exemption = @restriction.exemptions.find(params[:id])
    @exemption.destroy
    flash[:notice] = "Successfully destroyed exemption."
    respond_to do |format|
      format.html { redirect_to offering_restriction_exemptions_url(@offering, @restriction) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_restriction
    @restriction = @offering.restrictions.find params[:restriction_id]
    session[:breadcrumbs].add "#{@restriction.title}", offering_restriction_path(@offering, @restriction)
  end

  def add_exemptions_breadcrumbs
    session[:breadcrumbs].add "Exemptions", offering_restriction_exemptions_path(@offering, @restriction)
  end

end
