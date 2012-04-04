class PipelinePositionsGradeLevel < ActiveRecord::Base
  has_many :pipeline_positions_grade_levels_links, :dependent => :destroy
  has_many :pipeline_positions, :through => :pipeline_positions_grade_levels_links, :source => :service_learning_position
end