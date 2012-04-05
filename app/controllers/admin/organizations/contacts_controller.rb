class Admin::Organizations::ContactsController < Admin::OrganizationsController
  before_filter :fetch_organization
  before_filter :add_organization_contacts_breadcrumbs
  
  # GET /admin/organizations_contacts
  # GET /admin/organizations_contacts.xml
  def index
    @organization_contacts = @organization.contacts

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/organizations_contacts/1
  # GET /admin/organizations_contacts/1.xml
  def show
    @organization_contact = @organization.contacts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/organizations_contacts/new
  # GET /admin/organizations_contacts/new.xml
  def new
    @organization_contact = @organization.contacts.build
    
    if params[:unit]
      @unit_id = params[:unit]
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/organizations_contacts/1/edit
  def edit
    @organization_contact = @organization.contacts.find(params[:id])
  end

  # POST /admin/organizations_contacts
  # POST /admin/organizations_contacts.xml
  def create
    @organization_contact = @organization.contacts.build(params[:organization_contact])

    respond_to do |format|
      if @organization.save
        flash[:notice] = 'OrganizationContact was successfully created.'
        format.html { redirect_to(redirect_to_path || organization_contact_url(@organization, @organization_contact)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/organizations_contacts/1
  # PUT /admin/organizations_contacts/1.xml
  def update
    @organization_contact = @organization.contacts.find(params[:id])

    respond_to do |format|
      if @organization_contact.update_attributes(params[:organization_contact])
        flash[:notice] = 'OrganizationContact was successfully updated.'
        format.html { redirect_to(redirect_to_path || organization_contact_url(@organization, @organization_contact)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/organizations_contacts/1
  # DELETE /admin/organizations_contacts/1.xml
  def destroy
    @organization_contact = @organization.contacts.find(params[:id])
    @organization_contact.destroy

    respond_to do |format|
      format.html { redirect_to(redirect_to_path || organization_contacts_url(@organization)) }
    end
  end

  def undestroy
    @organization_contact = @organization.former_contacts.find(params[:id])
    @organization_contact.update_attribute :current, true

    respond_to do |format|
      format.html { redirect_to(redirect_to_path || organization_contacts_url(@organization)) }
    end
  end

  def send_login_link
    @organization_contact = @organization.contacts.find(params[:id])
    @unit = params[:unit] ? Unit.find_by_abbreviation(params[:unit]) : Unit.find_by_abbreviation("carlson")
    
    community_partner_mailer = CommunityPartnerMailer.create_community_partner_login_link(@organization_contact, @unit)
    # if @unit.abbreviation == "pipeline"
    #       community_partner_mailer = CommunityPartnerMailer.create_pipeline_login_link(@organization_contact)
    #     else 
    #       community_partner_mailer = CommunityPartnerMailer.create_service_learning_login_link(@organization_contact)
    #     end

    if EmailQueue.queue(@organization_contact.person.id, community_partner_mailer)
      flash[:notice] = "Login link e-mail queued for #{@organization_contact.fullname}."
    else
      flash[:error] = "Error queueing login link."
    end
    redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
    redirect_to(redirect_to_path || organization_contacts_url(@organization))
  end
  
  def move_organization_contact
    @old_organization = Organization.find(params[:organization_contact][:organization_id])
    @old_organization_contact = OrganizationContact.find(params[:organization_contact][:organization_contact_id])
    
    if params[:organization_contact][:move] == "true"
      @old_organization_contact.current = false
      @old_organization_contact.save
    end
    
    @organization_contact = OrganizationContact.new(:person_id => @old_organization_contact.person_id,
                                                    :organization_id => @organization.id)
    
    respond_to do |format|
      if @organization_contact.save
        flash[:notice] = 'OrganizationContact was successfully created.'
        format.html { redirect_to(redirect_to_path || organization_contact_url(@organization, @organization_contact)) }
      else
        flash[:error] = 'OrganizationContact could not be moved.'
        format.html { render :action => "new" }
      end
    end
  end
  
  protected
  
  def fetch_organization
    @organization = Organization.find(params[:organization_id])
  end

  def add_organization_contacts_breadcrumbs
    session[:breadcrumbs].add "Contact", organization_contacts_url(@organization)
  end
  
end


