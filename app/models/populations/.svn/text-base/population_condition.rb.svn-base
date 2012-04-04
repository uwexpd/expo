# Defines a condition that's used to refine a Population set. Many conditions can be applied to a single population. For example, if the population is a set of ApplicationForOfferings, a condition might be "status is in_progress." To define this condition, the user can specify three attributes:
# 
# * +attribute_name+ defines the attribute to evaluate, e.g., "status"
# * +eval_method+ defines the method to use for comparison, and it must be defined in the valid_criteria constant. e.g., "is"
# * +value+ defines the thing to compare to, e.g., "in_progress"
class PopulationCondition < ActiveRecord::Base
  belongs_to :population, :counter_cache => :conditions_counter
  validates_presence_of :attribute_name, :eval_method, :value, :unless => :skip_validations?

  DEFAULT_EVAL_METHODS = %w(== != < <= > >= include? match)

  attr_accessor :should_destroy
  def should_destroy?
    should_destroy == true || should_destroy == "true"
  end

  attr_accessor :skip_validations
  def skip_validations?
    skip_validations
  end

  # Determines if the object passes through this condition and returns true or false.
  def passes?(obj)
    method_key = valid_criteria[attribute_name]["operators"] rescue nil
    if method_key.nil?
      return false unless DEFAULT_EVAL_METHODS.include?(eval_method)
      t_eval_method = (eval_method == "match" || eval_method == "include?") ? ".#{eval_method}" : " #{eval_method}"
      eval_string = "obj.instance_eval(\"#{attribute_name}\")#{t_eval_method} \"#{value.to_s}\""
      # puts eval_string
      eval eval_string, binding
    else
      eval_string = method_key[eval_method]
      eval_string.gsub!("$1", "obj")
      eval_string.gsub!("$2", (values == "boolean" ? value : "\"#{value}\""))
      # puts eval_string
      eval eval_string, binding
    end
  end

  # Returns the possible valid criteria based on the population_criteria YAML file.
  def valid_criteria
    @valid_criteria ||= YAML::load(ERB.new((IO.read("#{RAILS_ROOT}/config/population_criteria.yml"))).result) || []
  end
  
  # Returns a hash of the possible values for this condition based on the valid_criteria.
  def values
    valid_criteria[attribute_name].nil? ? {} : valid_criteria[attribute_name]["values"]
  end

  # Tries to return the value for this PopulationCondition with its typecast set properly. Compare to simply calling
  # +value+, which will always return a String because that's what's stored in the DB.
  # 
  # * If +values+ returns "boolean" then return +true+ or +false+.
  # * If +values+ is a Hash and +values["ids"]+ is set to "id" then typecast value with +to_i+.
  # * Otherwise, simply return +value+.
  def value_with_typecast
    if values == "boolean"
      value == "true" ? true : false
    elsif values.is_a?(Hash) && values["ids"] == "id"
      value.to_i
    else
      value
    end
  end
  
  # Used for values that will be sourced from a collection. Evaluates the "collection" string from valid_criteria in the
  # populatable object for this condition's population.
  def values_collection
    collection_method = valid_criteria[attribute_name]["values"]["collection"]
    population.populatable.instance_eval(collection_method)
  end
  
  # Returns an array of the attributes that are defined in valid_criteria, suitable for a select dropdown.
  def possible_attributes
    custom_keys = valid_criteria.keys.sort
    klass = population.populatable.class.reflect_on_association(population.starting_set.try(:to_sym)).try(:class_name).try(:constantize) rescue nil
    p_codes = []; ap_codes = []
    if klass
      p_codes = klass::PLACEHOLDER_CODES || [] rescue []
      ap_codes = []
      for assoc in (klass::PLACEHOLDER_ASSOCIATIONS || [] rescue [])
        aklass = klass.reflect_on_association(assoc.to_sym).try(:class_name).try(:constantize)
        ap_codes << aklass::PLACEHOLDER_CODES.collect{|c| "#{assoc}.#{c}"} if aklass rescue nil
      end
    end
    all_keys = ((custom_keys + p_codes).flatten.sort + ap_codes.sort).flatten.compact.uniq.map{|k| [k.gsub("_", " ").gsub(".", " → "), k]}
  end
  
  # Returns an array of the possible eval_methods for the current +attribute+ that is set for this condition.
  def possible_eval_methods
    valid_criteria[attribute_name].nil? ? DEFAULT_EVAL_METHODS : valid_criteria[attribute_name]["operators"].keys.map{|k| [k.gsub("_", " "), k]}
  end
  
end