class CommunityPartner::ServiceLearning::OrganizationController < CommunityPartner::ServiceLearningController
  before_filter :add_to_breadcrumbs

  def show
  end

  def edit
    session[:breadcrumbs].add "Edit"
  end

  def update
    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        flash[:notice] = 'Your organization information was successfully updated.'
        format.html { redirect_to(community_partner_service_learning_organization_url(@quarter)) }
      else
        format.html { render :action => "edit" }
      end
    end
    
  end

  private
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Organization", "."
  end
  
end
