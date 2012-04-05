class OfferingAdminPhaseTaskExtraField < ActiveRecord::Base
  include ActionController::UrlWriter
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  
  stampable
  belongs_to :task, :class_name => "OfferingAdminPhaseTask", :foreign_key => "offering_admin_phase_task_id"
  
  validates_presence_of :offering_admin_phase_task_id
  validates_presence_of :title
  validates_presence_of :display_method
  
  def display(object)
    eval display_method rescue "#error"
  end
  
end
