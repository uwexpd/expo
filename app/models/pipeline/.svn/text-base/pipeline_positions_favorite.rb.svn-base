=begin rdoc
  Holds a students favorited positions
=end
class PipelinePositionsFavorite < ActiveRecord::Base
  belongs_to :service_learning_position, :foreign_key => "pipeline_position_id"
  belongs_to :service_learning_course
  belongs_to :person
end