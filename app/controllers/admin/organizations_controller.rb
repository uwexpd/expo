class Admin::OrganizationsController < Admin::BaseController
  before_filter :add_to_breadcrumbs
  
  # GET /organizations
  # GET /organizations.xml
  def index
    @organizations = Organization.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organizations }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    @organization = Organization.find(params[:id])
    session[:breadcrumbs].add @organization.name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/new
  # GET /organizations/new.xml
  def new
    @organization = Organization.new
    session[:breadcrumbs].add "New"
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
    session[:breadcrumbs].add @organization.name
  end

  # POST /organizations
  # POST /organizations.xml
  def create
    @organization = Organization.new(params[:organization])
    
    if params[:organization_type] == "School"
      @organization.update_attribute[:type] = "School"
      @organization.reload
    end
    
    respond_to do |format|
      if @organization.save
        flash[:notice] = 'Organization was successfully created.'
        format.html { redirect_to(redirect_to_path || admin_organization_path(@organization)) }
        format.xml  { render :xml => @organization, :status => :created, :location => @organization }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organizations/1
  # PUT /organizations/1.xml
  def update
    @organization = Organization.find(params[:id])
    
    if params[:organization_type] == "School"
      if @organization.class == Organization
        @organization.update_attribute(:type, "School")
        @organization.reload
      else
        params[:organization] = params[:school]
      end
    end
    
    if params[:organization_type] == "Organization" && @organization.class == School
      params[:organization] = params[:school]
      @organization.update_attribute(:type, "Organization")
      @organization = Organization.find(params[:id])
    end
    
    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        flash[:notice] = 'Organization was successfully updated.'
        format.html { redirect_to(redirect_to_path || admin_organization_path(@organization)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.xml
  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to(admin_organizations_url) }
      format.xml  { head :ok }
    end
  end
  
  def get_organization_contacts
    @organization = Organization.find(params[:organization_id])
    @organization_contacts = @organization.contacts
    
    respond_to do |format|
      format.js
    end
  end

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Organizations", "/organizations"
  end
  
  
end
