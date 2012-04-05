module CommunityPartner::ServiceLearning::PositionsHelper
  
  def add_time_link(name, options = {})
    link_to_function name, options do |page|
      page.insert_html :bottom, 
                        :times, 
                        :partial => 'admin/service_learning/organizations/positions/time', 
                        :object => ServiceLearningPositionTime.new
    end
  end

end
