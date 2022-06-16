class ServiceLearningPositionsSectorTypesLink < ActiveRecord::Base
  belongs_to :service_learning_positions, :foreign_key => "service_learning_position_id"
  belongs_to :service_learning_positions_sector_type
end