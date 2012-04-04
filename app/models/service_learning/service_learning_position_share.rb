=begin rdoc
  Model used to link share a service learning position between units
  the unit in this is the unit that the position is being shared with
  
  The allow_edit field is use to see if the unit the poisiton is shared with can edit the position
  
  TODO: All placements created by the shared unit will have the shared units id attached
=end
class ServiceLearningPositionShare < ActiveRecord::Base
  belongs_to :unit
  belongs_to :service_learning_position
  
  has_many :notes, :as => :notable, :dependent => :nullify
end