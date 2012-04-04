module Admin::ServiceLearning::PositionsHelper
  
  def organization_select_or_link(form)
    link_to @service_learning_position.organization.name, 
            service_learning_organization_path(@unit, @quarter, @service_learning_position.organization)
  end
  
end