class CommunityPartnerController < ApplicationController
  before_filter :initialize_breadcrumbs
  skip_before_filter :login_required, :only => [:map, :index, :map_to_new_user]
  skip_before_filter :check_for_limited_login
  before_filter :map_to_organization_contact, :except => [:map, :map_manually, :map_to_new_user]
  before_filter :login_required, :except => [:map, :map_to_new_user]
  before_filter :fetch_person, :fetch_organizations, :except => [:map, :map_manually, :map_to_new_user]
  before_filter :choose_organization, :except => [:which, :map, :map_manually, :profile, :map_to_new_user]
  before_filter :add_header_subtitle

  helper_method :get_breadcrumbs
  def get_breadcrumbs
    breadcrumbs
  end

  layout 'admin'

  def index
    fetch_person
    fetch_organizations
    choose_organization
    
    redirect_to community_partner_service_learning_home_path(nil, :unit => Unit.find_by_abbreviation("carlson").id)
    
    # @organization_units = @organization.organization_quarters.collect{|oq| oq.unit}.uniq
    # 
    # if @organization_units.size == 1
    #   redirect_to community_partner_service_learning_home_path(nil, :unit => @organization_units[0].id)
    # end
  
  end
  
  def which
    session[:breadcrumbs].add "Select Organization"
    session[:unit] = nil
    if params[:organization]
      if params[:organization][:id]
        session[:organization_id] = params[:organization][:id]
        redirect_to :action => 'index' # redirect_to_path || {:action => 'index'}
      end
    end
  end

  # Maps a user to the requested organization contact record without destroying in-place data.
  # 
  # 1. Finds OrganizationContact based on the ID and token passed in the +map+ and +t+ query parameters.
  # 2. If this OrganizationContact has a User associated with it, authenticate as the user and move on.
  # 3. If not, display a form so that we can create a new username and connect it to this OrganizationContact.
  def map
    if params[:map] && params[:t]
      @organization_contact = Token.find_object(params[:map], params[:t], false)
      if @organization_contact.nil?
        flash[:error] = "error"
        return redirect_to :action => "map_manually"
      end
      
      if @organization_contact.person && @organization_contact.person.users.first
        self.current_user = @organization_contact.person.users.first
        login_required
        successful_login
        @organization_contact.token.generate
        return redirect_to :action => "index"
      else
        @user = User.new
        @user.person = @organization_contact.person
      end      
    end
  end
  
  # Processes the form data sent from the #map action. Creates a new user with the information specified and links that
  # user to the existing Person record of the OrganizationContact specified in the URL token. If there's a validation
  # failure, render the #map action again.
  def map_to_new_user
    cookies.delete :auth_token
    @organization_contact = Token.find_object(params[:map], params[:t], false)
    @user = User.new
    if !@organization_contact
      @user.attributes = params[:user]
      @organization = Token.find_object(params[:organization_id], params[:organization_token], false)
      person = Person.create(params[:user][:person_attributes]) if @user.valid?
      @organization_contact = @organization.contacts.create(:person_id => person.try(:id)) if @user.valid?
    end
    if !@organization_contact
      flash[:error] = "We could not initialize your organization contact record."
      return render :action => "map"
    end
    @organization_contact.person.update_attributes(params[:user][:person_attributes])
    @user.attributes = params[:user].except(:person_attributes)
    @user.person = @organization_contact.person
    @user.email = params[:user][:person_attributes][:email] rescue nil
    @user.save!
    self.current_user = @user
    @organization_contact.token.generate
    redirect_to :action => "index"
    flash[:notice] = "Thanks for creating an account!"
    successful_login
  rescue ActiveRecord::RecordInvalid
    render :action => 'map'
  end
  
  def wrong_person
    session[:breadcrumbs].add "Wrong Person"
    @contacts = @organization.contacts
    
    if params[:new_contact_id] && params[:new_contact_id] != 'NEW'
      @organization_contact = @organization.contacts.find(params[:new_contact_id])
      return redirect_to :action => 'map', :map => @organization_contact.id, :t => @organization_contact.token.token
    elsif params[:new_contact_id] && params[:new_contact_id] == 'NEW'
      @organization_contact = @organization.contacts.new(:person_id => Person.new)
      @user = User.new
      return render :action => "map"
    end
    
  end
  
  # def map
  #   if params[:map] && params[:t]
  #     session[:breadcrumbs].add "Select Contact Information"
  #     organization_contact_id = params[:map]
  #     token = params[:t]
  #     @organization_contact = Token.find_object(organization_contact_id, token, false)
  #     if @organization_contact.nil?
  #       flash[:error] = "That community partner ID and temporary passphrase combination did not match. Please try again."
  #       redirect_to :action => "map_manually" and return
  #     end
  #     if params[:resolve_with]
  #       if params[:resolve_with] == 'organization_info'
  #         @current_user.person.update_attributes(@organization_contact.person.attributes)
  #         @organization_contact.update_attribute(:person_id, @current_user.person_id)
  #       elsif params[:resolve_with] == 'my_info'
  #         @organization_contact.update_attribute(:person_id, @current_user.person_id)
  #       end
  #       @organization_contact.token.generate
  #       redirect_to community_partner_profile_url
  #     end    
  #   else
  #     redirect_to :action => "map_manually"
  #   end
  # end
  
  def map_manually
    
  end
  
  def profile
    session[:breadcrumbs].add "Edit My Profile"
    if params[:person]
      @person.attributes = params[:person]
      @person.require_validations = true
      if @person.save
        flash[:notice] = "Successfully saved contact information."
        redirect_to :action => 'index' # redirect_to_path || {:action => 'index'}
      end
    end
  end

  protected
  
  def fetch_person
    return redirect_to login_url(:return_to => request.request_uri) unless logged_in?
    @person = @current_user.person
  end
  
  def fetch_organizations
    @organizations = @person.organizations
    if @organizations.empty?
      raise ExpoException.new("You are not listed as an organization contact.",
            "Our system does not list you as an organization contact for any organizations in our database. If you believe this to be an
            error, please contact your organization's main UW service-learning contact or contact the Carlson Center staff.") 
    end
  end
  
  def choose_organization
    if @organizations.size == 1
      @organization = @organizations.first
    else
      if session[:organization_id].blank?
        redirect_to :action => 'which'#, :return_to => request.request_uri
      else
        @organization = @organizations.find session[:organization_id]
        raise ExpoException.new("That is not a valid organization ID.") if @organization.nil?
      end
    end
  end

  # Maps this person to an OrganizationContact record if a valid token is sent with the URL.
  def map_to_organization_contact
    if params[:map] && params[:t]
      organization_contact_id = params[:map]
      token = params[:t]
      if @organization_contact = Token.find_object(organization_contact_id, token, false)
        return redirect_to community_partner_map_url(:map => params[:map], :t => params[:t])
      else
        flash[:error] = "That login link is no longer valid. Please e-mail <a href=\"mailto:serve@uw.edu\">serve@uw.edu</a>
                        for a new link -OR- login with your EXPO username and password below."
        session[:return_to] = community_partner_home_url
        return redirect_to login_url
      end
    end
  end

  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXP-Online", "/expo", :class => 'home'
    
    session[:breadcrumbs].add "Home", community_partner_home_url
  end

  def add_header_subtitle
    @header_subtitle = "&raquo; University of Washington Service-Learning Web Interface"
  end
  
  def successful_login
    LoginHistory.login(self.current_user, (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), request.session_options[:id])    
    session[:limit_login_to] = "/community_partner"
  end
  
  
end
