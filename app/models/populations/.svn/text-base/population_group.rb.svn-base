# Allows a user to group many Population objects (or other PopulationGroup objects) together for combined reporting. This can be useful for consolidating populations together (e.g., "2009 Mary Gates Scholars" could include scholarship winners from Autumn, Winter, and Spring 2009) or comparing populations in reporting (e.g., compare the demographic changes between the three quarters of 2009 Mary Gates Scholars).
class PopulationGroup < ActiveRecord::Base
  has_many :population_group_members
  has_many :parent_population_group_members, :class_name => "PopulationGroupMember", :as => :population_groupable
  
  validates_presence_of :title

  named_scope :everyone, :conditions => "access_level = 'everyone' OR access_level IS NULL"
  named_scope :creator, lambda { |user| { :conditions => { :creator_id => user.id, :access_level => 'creator' } } }
  named_scope :unit, lambda { |user| { :conditions => "creator_id IN (#{(user.units.collect(&:users).flatten.collect(&:id)+[0]).flatten.join(',') rescue nil}) AND access_level = 'unit'" } }

  default_scope :order => 'title'

  # Returns an array of Population objects. If any of the group members are a PopulationGroup, then this method
  # will call the #members method on that group and include all of the child populations.
  def members
    @members ||= population_group_members.collect(&:members).flatten.uniq
  end
  
  # Returns an array of objects from all of the associated Population objects.
  def objects
    @objects ||= population_group_members.collect(&:objects).flatten.uniq
  end
  
  # Adds a Population or PopulationGroup to this group if it is not already a member of this group. 
  # Returns the PopulationGroupMember that is created or found, or raises
  # an ActiveRecord::RecordNotFound exception if +p+ is not a Population or PopulationGroup.
  def add!(p)
    raise Exception.new("Object is not a Population or PopulationGroup") if !p.is_a?(Population) && !p.is_a?(PopulationGroup)
    population_group_members.find_or_create_by_population_groupable_type_and_population_groupable_id(p.class.to_s, p.id)
  end
  
  # Returns the oldest +objects_generated_at+ date for the members of this group.
  def objects_generated_at
    @objects_generated_at ||= members.collect(&:objects_generated_at).compact.min
  end
  
  # Returns the total count of objects for all members of this group.
  def objects_count
    @objects_count ||= objects.size
  end
  
end