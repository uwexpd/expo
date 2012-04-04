class OfferingAdminPhaseTaskCompletionStatus < ActiveRecord::Base
  belongs_to :task, :class_name => "OfferingAdminPhaseTask", :foreign_key => "task_id"
  belongs_to :taskable, :polymorphic => true
  
  validates_presence_of :task_id, :taskable_id, :taskable_type
  
  serialize :result
  
  stampable
  
end
