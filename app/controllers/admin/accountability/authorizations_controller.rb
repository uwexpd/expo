class Admin::Accountability::AuthorizationsController < Admin::AccountabilityController
  before_filter :add_users_breadcrumbs
  
  def index
    @role = Role.find_or_create_by_name "accountability_department_coordinator"
    @authorizations = @role.authorizations
    @departments = {}
    for authorization in @authorizations
      dept = authorization.authorizable
      @departments[dept] ||= []
      @departments[dept] << authorization
    end
  end

  def create
    if params[:uw_netid].blank? || params[:authorizable_key].blank?
      @error = "You must provide department and UW NetID."
    else
      @role = Role.find_or_create_by_name "accountability_department_coordinator"
      user = PubcookieUser.authenticate(params[:uw_netid]) unless params[:uw_netid].blank?
      role = user.assign_role(:accountability_department_coordinator)
      key = params[:authorizable_key]
      if m = key.match(/^NEW_(.+)/)
        @department = DepartmentExtra.find_or_create_by_fixed_name CGI.unescape(m[1])
      elsif m = key.match(/^(Department|DepartmentExtra)_(\d+)/)
        @department = m[1].constantize.find(m[2])
      else
        @error = "Invalid department name format."
      end
      @authorization = role.authorize_for(@department) unless @error
      @authorizations = @role.authorizations.find(:all, 
                          :conditions => { :authorizable_type => @department.class.to_s, :authorizable_id => @department.id })
      @error = "Error creating authorization record." unless @authorization
    end
  
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @authorization = UserUnitRoleAuthorization.find(params[:id])
    @department = @authorization.authorizable
    @role = Role.find_or_create_by_name "accountability_department_coordinator"
    @authorization.destroy

    @authorizations = @role.authorizations.find(:all, 
                        :conditions => { :authorizable_type => @department.class.to_s, :authorizable_id => @department.id })
  
    respond_to do |format|
      format.js
    end
  end

  def auto_complete_for_department
    @q = params[:department_search]
    @departments = Department.find(:all, :conditions => ["dept_full_nm LIKE ? OR dept_abbr = ?", "%#{@q}%", @q], :limit => 10)
    @departments << DepartmentExtra.find(:all, :conditions => ["fixed_name LIKE ? AND dept_code IS NULL", "%#{@q}%"], :limit => 10)
    @departments.flatten!
    render :partial => "auto_complete_for_department"
  end

  protected
  
  def add_users_breadcrumbs
    session[:breadcrumbs].add "Authorized Users", :action => 'index'
  end
end