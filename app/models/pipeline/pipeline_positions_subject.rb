class PipelinePositionsSubject < ActiveRecord::Base
  has_many :pipeline_positions_subjects_links, :dependent => :destroy
  has_many :pipeline_positions, :through => :pipeline_positions_subjects_links, :source => :service_learning_position
end