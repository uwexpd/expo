class PipelinePositionsSubjectsLink < ActiveRecord::Base
  belongs_to :service_learning_position, :foreign_key => "pipeline_position_id"
  belongs_to :pipeline_positions_subject
end