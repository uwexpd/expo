# Allows any ActiveRecord object be deep cloned, which includes associated objects. Based off http://blog.defv.be/2008/3/27/activerecord-deepclone-plugin.

module DeepClone
  def self.included(base) #:nodoc:
    base.alias_method_chain :clone, :deep_clone
  end

  # Clones an ActiveRecord model. 
  # if passed the :include option, it will deep clone the given associations
  # if passed the :except option, it won't clone the given attributes (on parent object or ANY child objects)
  #
  # === Usage:
  #   pirate.clone :except => :name
  #   pirate.clone :except => [:name, :nick_name]
  #   pirate.clone :include => :mateys
  #   pirate.clone :include => [:mateys, :treasures]
  #   pirate.clone :include => {:treasures => :gold_pieces}
  #   pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
  # 
  def clone_with_deep_clone options = {}
    transaction do 
      kopy = clone_without_deep_clone
      kopy.save
    
      if options[:except]
        Array(options[:except]).each do |attribute|
          kopy.write_attribute(attribute, attributes_from_column_definition[attribute.to_s])
        end
      end
    
      if options[:include]
        Array(options[:include]).each do |association, deep_associations|
          if (association.kind_of? Hash)
            deep_associations = association[association.keys.first]
            association = association.keys.first
          end
          opts = deep_associations.blank? ? {} : {:include => deep_associations}
          opts[:except] = options[:except] unless options[:except].blank?
          kopy.send("#{association}=", self.send(association).collect {|i| i.clone(opts) })
        end
      end
      
      kopy.save
      
      return kopy
    end
  end
end
