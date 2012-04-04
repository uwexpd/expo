# Keeps track of changes made to associated models.
class Change < ActiveRecord::Base
  stampable
  Change.partial_updates = false # disable partial_updates so that serialized columns get saved
  
  belongs_to :change_loggable, :polymorphic => true
  serialize :changes

  NON_TRACKED_ATTRIBUTES = %w(created_at updated_at deleted_at creator_id updater_id deleter_id
                              filled_placements_count unallocated_placements_count total_placements_count)

  named_scope :for, lambda { |klasses| { :conditions => self.conditions_for(klasses) } }  
  named_scope :last50, :order => "created_at DESC", :limit => 50
  named_scope :since, lambda { |time_ago| { :conditions => ['created_at > ?', time_ago] } }

  # Gets called after_create
  def self.log_create(obj)
    obj.changelogs.create(:action_type => 'create') if obj.respond_to?(:changelogs)
  end
  
  # Gets called after_update
  def self.log_update(obj)
    obj.changelogs.create(:action_type => 'update', :changes => cleanup_changes(obj.changes)) if obj.respond_to?(:changelogs) && obj.changed?
  end
  
  # Gets called after_delete
  def self.log_delete(obj)
   if obj.class.respond_to?(:deleted_class)
     c = obj.changelogs.create(:action_type => 'delete') if obj.respond_to?(:changelogs)
     c.update_attribute(:change_loggable_type, obj.class.deleted_class.to_s)
   end
  end

  # Gets called before_create
#   def self.log_undelete(obj)
#     if obj.respond_to?(:changelogs)
# #      c = obj.changelogs.create(:action_type => 'create')
#       # c.update_attribute(:action_type, 'undelete') unless obj.deleted_at.blank?
#       logger.info { obj.class }
#       logger.info { obj.attributes.to_yaml }
#     end
#   end

  # Returns the "identifier_string" for the associated changed object. ChangeLoggable models should include an +identifier_string+
  # method to assist with this.
  def identifier_string
    change_loggable.identifier_string rescue "unknown"
  end

  # Finds Changes that have occurred for the specified class, as well as for the deleted version of the class (if it exists)
  def self.for_class(*klass)
    results = []
    klass.each do |k|
      results << self.find_all_by_change_loggable_type(k.to_s)
      results << self.find_all_by_change_loggable_type(k.deleted_class.to_s) if k.respond_to?(:deleted_class)
    end
    results.flatten.uniq
  end
  
  protected
  
  # Cleans up the object's @changes hash so that we don't bother storing changes to things like +updated_at+ and +creator_id+
  def self.cleanup_changes(h)
    h.reject{|key,val| NON_TRACKED_ATTRIBUTES.include?(key)}
  end
  
  # Used in the +for+ named_scope. Generates a valid array for use as a SQL :conditions paramater. Can accept an array of
  # Class names or a single Class name, and will automatically include the class's deleted_class equivalent if the model
  # is setup to use acts_as_soft_deletable (this way we can retrieve changes from the changelog that include deleted records).
  def self.conditions_for(klasses)
    klasses = [klasses] unless klasses.is_a?(Array)
    first = true; str = ""; params = []
    klasses.each do |k|
      str << ' OR ' unless first; first = false
      str << ' change_loggable_type = ? '
      str << ' OR change_loggable_type = ? ' if k.respond_to?(:deleted_class)
      params << k.to_s
      params << k.deleted_class.to_s if k.respond_to?(:deleted_class)
    end
    conditions = [str, params].flatten
  end
  
end