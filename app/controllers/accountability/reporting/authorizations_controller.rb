class Accountability::Reporting::AuthorizationsController < Accountability::ReportingController
  before_filter :add_users_breadcrumbs
  skip_before_filter :fetch_service_learning_courses
  
  def index
    @authorizations = @department.accountability_coordinator_authorizations
  end

  def create
    user = PubcookieUser.authenticate(params[:uw_netid]) unless params[:uw_netid].blank?
    role = user.assign_role(:accountability_department_coordinator)
    @authorization = role.authorize_for(@department)

    respond_to do |format|
      # if @authorization.save
      #   # flash[:notice] = "@department.accountability_coordinator_authorizations was successfully created."
      #   # format.html { redirect_to(accountability_reporting_authorizations_url(@year)) }
      #   
      # else
      #   # format.html { render :action => "new" }
      # end
      format.js
    end
  end

  def destroy
    @authorization = @department.accountability_coordinator_authorizations.find(params[:id])
    @authorization.destroy

    respond_to do |format|
      format.html { redirect_to(accountability_reporting_authorizations_url(@year)) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected
  
  def add_users_breadcrumbs
    session[:breadcrumbs].add "Authorized Users", accountability_reporting_authorizations_url(@year)
  end
end