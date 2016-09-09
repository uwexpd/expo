class PipelinePositionsLanguageSpoken < ActiveRecord::Base
  has_many :pipeline_positions_language_spoken_links, :dependent => :destroy
  has_many :pipeline_positions, :through => :pipeline_positions_language_spokens_links, :source => :service_learning_position
end
