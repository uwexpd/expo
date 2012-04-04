# A Population defines a group of objects that can be compared or reported on elsewhere in EXPO. A Population is defined by selecting a starting object, defined by the "populatable" relationship. Within that, you select the "starting set" of objects to use, which will link to a has_many relationship in the starting object. Finally, a number of PopulationConditions are added on to the Population definition to further refine the selection of individual objects for inspection.
# 
# == Attributes
# The attributes are as follows:
# 
# *  +title+: The title of the Population. Required.
# *  +description+: A brief description, if desired.
# *  +populatable+: The starting object to use. Required.
# *  +starting_set+: The name of the relationship or method in the starting object that will return an array of objects as a starting point. Required.
# *  +condition_operator+: Defines how to compare the conditions. "any" will find objects in the starting set that meet any of the conditions; "all" will require that objects meet every condition. Default is "all".
# *  +access_level+: Default is creator.
#    * everyone - any user will see this population in lists
#    * unit - other users in the population creator's unit will see this population in lists
#    * creator (or blank) - only the creator of the population will be shown it.
# 
# == System Populations
# A population can be created by the system (instead of by a user) and marked with the +system?+ boolean. These populations
# do not show up in lists of populations until a user saves them manually.
class Population < ActiveRecord::Base
  stampable
  
  belongs_to :populatable, :polymorphic => true
  has_many :conditions, :class_name => "PopulationCondition"
  
  has_many :population_group_members, :as => :population_groupable
  has_many :population_groups, :through => :population_group_members
  
  validates_presence_of :title
  # validates_presence_of :populatable, :starting_set, :on => :update, :unless => :custom_query?
  # validates_associated :populatable, :unless => :custom_query?
  validates_uniqueness_of :title, :scope => :creator_id

  # before_save :empty_conditions_if_needed
  after_update :save_conditions

  serialize :object_ids

  named_scope :everyone, :conditions => "access_level = 'everyone' OR access_level IS NULL"
  named_scope :creator, lambda { |user| { :conditions => { :creator_id => user.id, :access_level => 'creator' } } }
  named_scope :unit, lambda { |user| { :conditions => "creator_id IN (#{(user.units.collect(&:users).flatten.collect(&:id)+[0]).flatten.join(',') rescue nil}) AND access_level = 'unit'" } }

  default_scope :order => 'title', :conditions => "deleted IS NULL OR deleted = 0 AND type != 'ManualPopulation'"
  
  named_scope :user_created, :conditions => "system IS NULL OR system = 0"

  # Returns all deleted populations.
  def self.deleted
    self.with_exclusive_scope { find(:all, :conditions => { :deleted => true }, :order => "deleted_at DESC") }
  end

  def self.find_with_deleted(id)
    Population.with_exclusive_scope { find_by_id_and_deleted(id, true) }
  end

  # The result set of objects in this population, after all of the conditions are applied. Returns the cache of +@objects+ if
  # available (Pass true to always regenerate +@objects+).
  def objects(force = false)
    @objects = generate_objects! if force || objects_generated_at.blank?
    collect_objects
  end

  # Alias for #objects(true).
  def objects!
    objects(true)
  end

  # Returns true if there is a value in the +custom_query+ attribute.
  def custom_query?
    !custom_query.blank?
  end

  # Returns true if there is a value in the +custom_result_variant+ attribute.
  def custom_result_variant?
    !custom_result_variant.blank?
  end
  
  # If a custom_result_variant is defined, return that. Otherwise return the result_variant value.
  def result_variant
    custom_result_variant? ? custom_result_variant : read_attribute(:result_variant)
  end

  # Returns the condition_operator attribute as a symbol, or :all if the database attribute is blank.
  def condition_operator
    return :all if read_attribute(:condition_operator).blank?
    read_attribute(:condition_operator).to_sym
  end

  # Returns true if the condition_operator is :any
  def any?
    condition_operator == :any
  end

  # Returns true if the condition_operator is :all
  def all?
    condition_operator == :all
  end

  # Finds all models that are defined and provides the model names as Strings in an array. This may take a moment
  # because it goes through and loads all files in the "/app/models" directory and subdirectories. The following models
  # are removed from the final array:
  # 
  #  * Anything that is a subclass of StudentInfo
  #  * The StudentInfo model itself
  #  * Any "::Deleted" model
  def self.model_names
    return @model_names if @model_names
    all_models = Dir.glob( File.join( RAILS_ROOT, 'app', 'models', '**', '*.rb') ).map{|path| path[/.+\/(.+).rb/,1].camelize.constantize }
    ar_models = all_models.select{|m| m < ActiveRecord::Base }
	  lmodels = ar_models.reject{|m| StudentInfo.send(:subclasses).include?(m) || m==StudentInfo || m.to_s.include?("CGI::") }
	  lmodels = lmodels.reject{|m| m.to_s.include?("::Deleted") }
    @model_names = lmodels.collect(&:to_s)
  end

  # Instead of returning *all* of the model names in existence (see #model_names), Just return a select list:
  def self.preferred_model_names
    models = %w(AwardType Committee CommitteeMember Equipment Event 
                Offering Organization Population PopulationGroup 
                Quarter Unit Role)
  end

  # Saves or creates conditions.
  def condition_attributes=(condition_attributes)
    condition_attributes.each do |condition_id, attributes|
      if attributes[:id].blank?
        conditions.build(attributes)
      else
        condition = conditions.detect{ |c| c.id == condition_id.to_i }
        condition.attributes = attributes
      end
    end
  end

  def save_conditions
    conditions.each do |c|
      if c.should_destroy?
        c.destroy
      else
        c.save(false)
      end
    end
  end

  # Generates the objects array by looping through all of the conditions. We separate this from the public
  # +objects+ method so that we can take advantage of caching better.
  # 
  # * If "any": Go through each condition. If we hit a true, add it to the "keep" list.
  # * If "all": Go through each condition. If we hit a false, remove that object.
  # 
  # Instead of returning the objects directly referenced by the query, you can also specify a +result_variant+
  # that will be called on each result object. For instance, if this population finds a collection of
  # Offering objects, you could specify "awardees" for the +result_variant+ to return the awardees from each
  # Offering instead of just the Offering objects. Note that this is not used for custom queries.
  def generate_objects!
    if custom_query?
      results = eval(custom_query)
    else
      objects = any? ? [] : starting_objects.clone
      objects_to_delete = []
      puts "Evaluating #{starting_objects.size} objects and #{conditions.size} condition(s)..."
      for obj in starting_objects
        # print "\n   #{obj.id}: "
        for condition in conditions
          # print " [C#{condition.id}:"
          if condition.passes?(obj)
            # print "PASS]"
            objects << obj and break if any?
          else
            # print "FAIL]"
            objects_to_delete << obj and break if all?
          end
        end
      end
      results = objects - objects_to_delete
      unless result_variant.blank?
        results = results.collect{|r| r.instance_eval(result_variant)}.flatten
      end
    end
    update_object_ids(results)
    update_attribute(:objects_generated_at, Time.now)
    update_attribute(:objects_count, self.object_ids.values.flatten.uniq.size)
    results
  end

  # Returns an array of output_fields that the user has specified and stored in the model as a JSON string.
  def output_fields
    fields = read_attribute(:output_fields).blank? ? [] : (ActiveSupport::JSON.decode(read_attribute(:output_fields)) || [])
  end

  # Gets the class name of the first object in the #starting_objects
  def starting_objects_class
    starting_objects.first.class rescue nil
  end

  # Removes the "deleted" flag from the record.
  def undestroy
    self.update_attribute(:deleted, nil)
    self.update_attribute(:deleted_at, nil)
  end
  
  # Overwrites the destroy method to just mark the "deleted" flag
  def destroy
    self.update_attribute(:deleted, true)
    self.update_attribute(:deleted_at, Time.now)
  end

  # Clone
  def clone!
    opts = {}
    opts[:except] = [:object_ids]
    opts[:include] = [:conditions]
    p2 = self.clone(opts)
    p2.update_attribute(:title, p2.title + " Copy")
    until p2.valid? && !p2.errors.on(:title)
      if p2.title[/\d+$/].nil?
        p2.title += " 2"
      else
        new_num = p2.title[/\d+$/].to_i + 1
        p2.title.gsub!(/\d+$/, new_num.to_s)
      end
    end 
    p2.save
    p2
  end

  protected
  
  # Pulls the starting set of objects from the populatable object.
  def starting_objects
    return [] if populatable.nil?
    populatable.instance_eval(starting_set.to_s)
  end

  # Collects the objects based on the object_ids instead of re-generating the entire collection. Note that this will not return
  # duplicate objects because of the way that ActiveRecord#find works with array parameters.
  def collect_objects
    results = []
    generate_objects! if object_ids.nil?
    begin
      object_ids.each do |model_name, ids|
        results << model_name.to_s.constantize.find(ids)
      end
      results.flatten
    rescue ActiveRecord::RecordNotFound
      generate_objects!
      collect_objects
    end
  end
  
  # Creates the object_ids hash which stores the object IDs for easy access in the form { ModelName => [id1, id2, ..., idn] }
  def update_object_ids(results)
    self.object_ids = {}
    results.each do |r|
      self.object_ids[r.class.to_s.to_sym] ||= []
      self.object_ids[r.class.to_s.to_sym] << r.id
    end
    self.save
  end
  
end
