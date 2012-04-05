class AddUnitToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :unit_id, :integer
    
    # fill in the added unit attribute
    unit = Unit.find_by_abbreviation "carlson"
    ServiceLearningPosition.all.each do |slp|
      slp.write_attribute(:unit_id,unit.id)
    end
    unit = Unit.find_by_abbreviation "pipeline"
    PipelinePosition.find(:all).each do |pp|
      pp.write_attribute(:unit_id,unit.id)
    end
  end
  
  def self.down
    remove_column :service_learning_positions, :unit_id
  end
end
