module ActiveRecord
  
  # Extends ActiveRecord to include a 'find_and_sort' method that allows for easy sorting of collections based on
  # database attributes _or_ regular instance methods.
  module FindAndSort
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      # Finds the records requested and sorts on the field (or code) specified in the +order+ parameter.
      # If the collection objects have a real (in the database) attribute for the search key, this method adds the order to the
      # regular +find+ method using the :order argument. Otherwise, we call +sort_by+ on the resulting collection and
      # return that.
      # 
      # == Examples
      # 
      # All sorting is done in the database query because +firstname+ is a database field.
      #   Person.find_and_sort(:all, :order => :firstname)
      # 
      # Sorting happens after the fact (slower) because +fullname+ is not in the database; it is a method.
      # Note that "ASC" and "DESC" are still usable in this context as well.
      #   Person.find_and_sort(:all, :order => :fullname)
      #   Person.find_and_sort(:all, :order => "fullname DESC")
      # 
      # The :order parameter can also be a code snippet that will be instance_eval'd on the object (slowest).
      #   Person.find_and_sort(:all, :order => "majors.include?('BIO')")
      # 
      # == Limitations
      # 
      # This method can only accept a single :order parameter. If multiple are given (e.g., "lastname, firstname"),
      # only the first parameter ("firstname", in this case) is used.
      def find_and_sort(*args)
        options = args.extract_options!
        pp options
        if options[:order]
          field = options[:order].to_s.split[0]
          direction = options[:order].to_s.split[1] || "ASC"        
          if columns_include?(field)
            results = find(args.first, options)
          else #if instance_methods.include?(field)
            results = find(args.first, options.delete(:order))
            results = results.sort_by{|r| r.instance_eval(field) rescue "" }
            results = results.reverse if direction == "DESC"
          # else
          #   raise InvalidField, "The sort field you provided is not a valid field or method name for this object."
          end
        end
        results
      end
      
      protected
      
      def columns_include?(column)
        columns.collect(&:name).include?(column.to_s)
      end
      
    end
    
    class InvalidField < Exception; end
  end
end