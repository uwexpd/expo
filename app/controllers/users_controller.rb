class UsersController < ApplicationController
  skip_before_filter :login_required, :check_authorization
  skip_before_filter :check_for_limited_login
  
  layout 'welcome'
  
  # render new.rhtml
  def new
    @user = User.new
  end

  def update
    @user = self.current_user
    @user.person.require_validations = true
    if @user.update_attributes(params[:user])
      @user.person.update_attribute(:contact_info_updated_at, Time.now)
      flash[:notice] = "Thanks for updating your profile!"
      redirect_to redirect_to_path || profile_path
    else
      render :action => "profile"
    end
  end

  def profile
    @user = self.current_user
    @user.valid?
  end

  def create
    cookies.delete :auth_token    
    @user = User.new(params[:user])
    if User.find_by_email params[:user][:person_attributes][:email].strip, :conditions => 'type IS NULL'
      flash.now[:error] = "This email address is already in use. <small>#{@template.link_to('Forgot your username/password?', :controller => 'session', :action => 'forgot')}</small>"
      render :action => 'new'
    else      
      @user.email = params[:user][:person_attributes][:email] rescue nil
      @user.save!
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
      if email = UserMailer.deliver_welcome_signup(@user)
        EmailContact.log(@user.person, email)
      end
      successful_login
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  protected
  
  def successful_login
    LoginHistory.login(self.current_user, (request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]), session.session_id)    
    session[:limit_login_to] = nil
  end
  

end
