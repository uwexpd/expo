class PipelinePositionsTutoringType < ActiveRecord::Base
  has_many :pipeline_positions_tutoring_types_links, :dependent => :destroy
  has_many :pipeline_positions, :through => :pipeline_positions_tutoring_types_links, :source => :service_learning_position
end