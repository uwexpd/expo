class CommunityPartner::ServiceLearning::ContactsController < CommunityPartner::ServiceLearningController
  before_filter :add_contacts_breadcrumbs
  
  # GET /community_partner/service_learning/organization_contacts
  # GET /community_partner/service_learning/organization_contacts.xml
  def index
    @organization_contacts = @organization.contacts.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /community_partner/service_learning/organization_contacts/1
  # GET /community_partner/service_learning/organization_contacts/1.xml
  def show
    @organization_contact = @organization.contacts.find(params[:id])
    session[:breadcrumbs].add @organization_contact.fullname

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization_contact }
    end
  end

  # GET /community_partner/service_learning/organization_contacts/new
  # GET /community_partner/service_learning/organization_contacts/new.xml
  def new
    @organization_contact = @organization.contacts.build
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization_contact }
    end
  end

  # GET /community_partner/service_learning/organization_contacts/1/edit
  def edit
    @organization_contact = @organization.contacts.find(params[:id])
    session[:breadcrumbs].add @organization_contact.fullname, "."
    session[:breadcrumbs].add "Edit"
    
  end

  # POST /community_partner/service_learning/organization_contacts
  # POST /community_partner/service_learning/organization_contacts.xml
  def create
    @organization_contact = @organization.contacts.new(params[:organization_contact])
    @organization_contact.person.require_validations = true

    respond_to do |format|
      if @organization_contact.save
        flash[:notice] = 'Contact was successfully created. '
        if params[:send_login_link]
          @organization_contact.token.generate rescue @organization_contact.create_token
          EmailContact.log @organization_contact.person.id, CommunityPartnerMailer.deliver_service_learning_login_link(@organization_contact)
          flash[:notice] << "Login link sent."
        end
        format.html { redirect_to(community_partner_service_learning_organization_contacts_url) }
        format.xml  { render :xml => @organization_contact, :status => :created, :location => @organization_contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organization_contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /community_partner/service_learning/organization_contacts/1
  # PUT /community_partner/service_learning/organization_contacts/1.xml
  def update
    @organization_contact = @organization.contacts.find(params[:id])
    @organization_contact.person.require_validations = true
    
    respond_to do |format|
      if @organization_contact.update_attributes(params[:organization_contact])
        flash[:notice] = 'Contact was successfully updated.'
        format.html { redirect_to(community_partner_service_learning_organization_contact_url(@quarter, @organization_contact)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organization_contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /community_partner/service_learning/organization_contacts/1
  # DELETE /community_partner/service_learning/organization_contacts/1.xml
  def destroy
    @organization_contact = @organization.contacts.find(params[:id])
    @organization_contact.destroy

    respond_to do |format|
      format.html { redirect_to(community_partner_service_learning_organization_contacts_url) }
      format.xml  { head :ok }
    end
  end
  
  def send_login_link
    @organization_contact = @organization.contacts.find(params[:id])
    @organization_contact.token.generate rescue @organization_contact.create_token
    if EmailContact.log @organization_contact.person.id, CommunityPartnerMailer.deliver_service_learning_login_link(@organization_contact)
      flash[:notice] = "Login link sent to #{@organization_contact.fullname}."
    else
      flash[:error] = "Error sending login link."
    end
    redirect_to community_partner_service_learning_organization_contacts_url(@quarter)
  end
  
  private
  
  def add_contacts_breadcrumbs
    session[:breadcrumbs].add "Organization", community_partner_service_learning_organization_path
    session[:breadcrumbs].add "Contacts", community_partner_service_learning_organization_contacts_path
  end
  
end
