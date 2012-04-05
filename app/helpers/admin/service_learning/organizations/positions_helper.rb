module Admin::ServiceLearning::Organizations::PositionsHelper
  
  def add_time_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :times, :partial => 'admin/service_learning/organizations/positions/time', :object => ServiceLearningPositionTime.new
    end
  end

end