class ModelHelpText < HelpText
  stampable
  validates_presence_of :object_type, :attribute_name
  
  # Returns the corresponding ModelHelpText for the information that's passed to it.
  # 
  # * Pass a model name constant to get all ModelHelpTexts for that model.
  # * Pass a model name constant and attribute name (in symbol form) to get the help text just for that attribute.
  # * Pass an object and attribute name (in symbol form) and the model name will be inferred.
  # 
  # If there is no matching help text for the arguments passed, +nil+ is returned.
  def self.for(*args)
    if args.size == 1 && args.first.is_a?(Class)
      results = ModelHelpText.find(:all, :conditions => { :object_type => args.first.to_s })
    else
      model_type = args[0].is_a?(Class) ? args[0] : args[0].class
      results = ModelHelpText.find(:first, :conditions => { :object_type => model_type.to_s, :attribute_name => args[1].to_s })
    end
    results == [] ? nil : results
  end

  # Creates or updates the attributes for a ModelHelpText.
  def self.set(model_name, attribute_name, values)
    model_name = model_name.constantize
    obj = ModelHelpText.for(model_name, attribute_name) || ModelHelpText.new(:object_type => model_name.to_s, :attribute_name => attribute_name)
    puts obj.inspect
    obj.attributes = values
    puts obj.inspect
    obj.save
    puts obj.inspect
    puts obj.errors.inspect
  end
  
end