module Admin::ServiceLearningHelper

  def service_learning_auto_complete_field(obj, method, title, quarter, accesskey = nil)
    label(obj, method, title) +
    text_field(obj, method, :accesskey => accesskey) +
    content_tag("div", "", :id => "#{obj}_#{method}_auto_complete", :class => "auto_complete right") +
    auto_complete_field("#{obj}_#{method}", 
      :url => service_learning_auto_complete_path(@unit, quarter, "auto_complete_for_#{obj}_#{method}"),
      :skip_style => true )  
  end
  
end
