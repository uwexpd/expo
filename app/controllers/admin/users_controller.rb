class Admin::UsersController < Admin::BaseController
  before_filter :users_breadcrumbs

  require_role :user_manager
  
  def index
    session[:breadcrumbs].add "List"
    @users = User.paginate :all, :order => 'identity_type DESC, login ASC', :page => params[:page], :include => [:person, :latest_login]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def admin
    session[:breadcrumbs].add "Admin Users"
    @users = User.paginate :all, 
                          :conditions => { :admin => true }, 
                          :order => 'identity_type DESC, login ASC', 
                          :page => params[:page], 
                          :include => [:person, :latest_login]
    render :action => "index"
  end
  
  def units_roles
    session[:breadcrumbs].add "Units ↔ Roles"
    @units = Unit.all
  end
  
  def roles_users
    session[:breadcrumbs].add "Roles ↔ Users"
    @roles = Role.all
  end
  
  def show
    @user = User.find(params[:id], :include => :logins)
    session[:breadcrumbs].add @user.login

    if params['tab']
      render :partial => "admin/users/tabs/#{params[:tab]}" and return
    end
    
  end

  def edit
    @user = User.find(params[:id])
    session[:breadcrumbs].add "#{@user.login}", @user
    session[:breadcrumbs].add "Edit"
  end

  def create
    if params[:user] && !params[:user][:login].blank?
      @user = PubcookieUser.authenticate params[:user][:login]
    end
    redirect_to :action => 'search', :search => { :login => (params[:user][:login] rescue nil) }
  end

  def update
    @user = User.find(params[:id])
    attributes = @user.is_a?(PubcookieUser) ? params[:pubcookie_user] : params[:user]

    respond_to do |format|
      if @user.update_attributes(attributes)
        @user.admin = attributes[:admin] # we have to manually override the :admin boolean because it is protected
        @user.save
        flash[:notice] = "User was successfully updated."
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def search
    session[:breadcrumbs].add "Search"
    conditions = params[:search] ? ["login LIKE ?", "%#{params[:search][:login].strip}%"] : nil
    @users = User.paginate :all, :order => 'identity_type DESC, login ASC', 
                            :conditions => conditions, 
                            :page => params[:page], :include => [:person, :latest_login]
    render :action => "index"
  end

  def history
    @logins = LoginHistory.paginate :all, :order => 'created_at DESC', :page => params[:page]
    session[:breadcrumbs].add "Login History"
  end

  def session_history
    @requests = SessionHistory.find(:all, :conditions => ['session_id = ?', params[:id]], :order => 'created_at ASC')
    if @requests.empty?
      flash[:error] = "Please specify a valid session ID."
      redirect_to :action => "index" and return
    end
    @start_time = @requests.first.created_at
    session[:breadcrumbs].add "Session History"
  end
  
  protected
  
  def users_breadcrumbs
    session[:breadcrumbs].add "Users", :action => 'index'
  end
  
end
