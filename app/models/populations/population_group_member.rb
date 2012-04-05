class PopulationGroupMember < ActiveRecord::Base
  belongs_to :population_group
  belongs_to :population_groupable, :polymorphic => true
  
  def members
    return [] if population_groupable.nil?
    population_groupable.is_a?(PopulationGroup) ? population_groupable.members : [population_groupable]
  end
  
  def objects
    return [] if population_groupable.nil?
    population_groupable.objects
  end
  
  
end