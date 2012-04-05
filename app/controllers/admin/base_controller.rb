class Admin::BaseController < ApplicationController
  before_filter :admin_required, :except => [ 'remove_vicarious_login' ]
  before_filter :initialize_breadcrumbs
  before_filter :check_ferpa_reminder_date, :except => [ 'ferpa_reminder', 'ferpa_statement', 'remove_vicarious_login', 'vicarious_login' ]

  layout 'admin'
  
  def index
   session[:breadcrumbs].add "Admin Area" 
   @my = @current_user.person
  end

  helper_method :get_breadcrumbs
  def get_breadcrumbs
    breadcrumbs
  end
  
  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXPO Admin Area", admin_welcome_url, {:class => "home"}
  end
  
  auto_complete_for :pubcookie_user, :login
  
  def person_fields
    if params[:id]
      @person = Person.find(params[:id])
      render :partial => "shared/person_fields", :object => @person
    end
  end

  def ferpa_reminder
    session[:breadcrumbs].add "FERPA Policies Reminder"
    
    if request.post? && params[:commit]
      @current_user.update_attribute(:ferpa_reminder_date, Time.now)
      redirect_to redirect_to_path and return
    end
  end
  
  def ferpa_statement
    session[:breadcrumbs].add "Statement of Responsibilities Regarding FERPA Requirements"
  end

  def uwsdb_reconnect
    @quarter = Quarter.current_quarter
    render :action => 'uwsdb_reconnect', :layout => false
  end

  def vicarious_login
    if params[:login]
      identity_type = params[:identity_type].blank? ? nil : params[:identity_type]
      user = User.find_by_login_and_identity_type(params[:login], identity_type)
    elsif params[:user_id]
      user = User.find(params[:user_id])
    else
      flash[:error] = "You need to provide either a user ID or a username and identity type."
      return redirect_to :action => "index"
    end
    if user
      return check_permission(:vicarious_login) unless @current_user.has_role?(:vicarious_login)
      session[:original_user] = @current_user.id
      session[:vicarious_token] = user.token
      session[:vicarious_user] = user.id
      flash[:notice] = "You are now logged in as #{user.fullname}."
      return redirect_to :action => "index"
    else
      flash[:error] = "Could not find the user you requested. Try looking for a different identity type for that user."
      return redirect_to :action => "index"
    end
  end
  
  def remove_vicarious_login
    session[:user] = session[:original_user]
    session[:original_user] = nil
    session[:vicarious_token] = nil
    session[:vicarious_user] = nil
    redirect_to :back
  end

  protected
  
  def check_ferpa_reminder_date
    if @current_user.ferpa_reminder_date.nil? || @current_user.ferpa_reminder_date < 3.months.ago
      redirect_to admin_ferpa_reminder_url(:return_to => request.request_uri) and return
    end
  end

  def self.require_role(role, options = {})
    method_name = 'require_role_' + role.to_s
    define_method method_name do
      self.check_permission(role)
    end
    protected method_name
    before_filter method_name.to_sym, options
  end

  def check_permission(role)
    unless @current_user.has_role?(role)
      @role = role.to_s.titleize
      return render :template => "exceptions/permission_denied", :status => :unauthorized
    end
  end

  def require_user_unit(unit, options = {})
    unless @current_user.in_unit?(unit)
      @unit = unit
      return render :template => "exceptions/wrong_unit", :status => :unauthorized
    end
  end


end
