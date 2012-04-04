class TextTemplate < ActiveRecord::Base
  stampable
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  named_scope :non_email, :conditions => {:type => nil}
  
  CONDITIONAL_REGEXP = /(%\?\((.+?)\)\?%)(.+?)(%\?%?)[\r|\n]??/m
  ATTRIBUTE_REGEXP = /\%([a-z0-9_.]+)\%/
  
  # Parses the supplied body text using the object and link passed to it:
  #
  # * +?(conditional)? text to include ?(end)?+ will be included if +conditional+ evaluates to +true+. Conditionals can use the
  #    instance variable names that match the object names passed in the +object+ hash.
  # * If +link+ is not a hash, +%link%+ will be replaced by the value of +link+.
  # * If +link+ is a hash, +%link_name%+ will be replaced by the value of +link+ matching +link_name+.
  # * If +object+ is not a hash, +%attribute%+ will be evaluated as +object.attribute+.
  # * If +object+ is a hash, then each +%model.attribute%+ will be evaluated as +object[:model].attribute+.
  # 
  # Pass the :sample option to include some HTML wrapping around attributes and conditionals (helpful for
  # email previews).
  def self.parse(body_text, object, link = nil, options = {})

    # Setup instance variables for the passed object
    if object.is_a?(Hash)
      object.each {|obj_name, obj| instance_variable_set("@#{obj_name}", obj) }
    end

    # Parse out the conditional statements
    t = body_text.to_s.gsub(CONDITIONAL_REGEXP) do |s| 
      rescued_output = options[:sample] ? "<span class='highlight red'>#{s}</span>" : ""
      show_value = object.instance_eval(s[$2]) rescue :error
      if show_value == :error
        rescued_output
      elsif show_value == true
        prefix =  "<span class='blue-background'>" if options[:sample]
        suffix = "</span>" if options[:sample]
        output = show_value ? s[$3].strip : "" rescue rescued_output
        "#{prefix}#{output}#{suffix}" rescue rescued_output
      else
        ""
      end
    end
    prefix = nil; suffix = nil;

    # Convert links
    if !link.nil? && !link.is_a?(Hash)
      t = t.gsub("%link%", link)
    elsif !link.nil?
      link.each do |link_name, link_text|
        t = t.gsub("%#{link_name}%", link_text)
      end
    end

    # text = params[:email][:body].gsub(TextTemplate::ATTRIBUTE_REGEXP) { |a| "<span class='highlight'>" +
    #       eval("@recipient_sample.#{a[$1]}") +
    #       "</span>" rescue "<span class='highlight red'>%#{a}%</span>" }      
    # 

    # Parse out the attributes for a single object
    prefix = "<span class='highlight'>" if options[:sample]
    suffix = "</span>" if options[:sample]
    
    if !object.is_a?(Hash)
      t = t.gsub(ATTRIBUTE_REGEXP) { |m| "#{prefix}#{object.instance_eval(m[$1]) rescue nil}#{suffix}" }
      
    # Parse out the attributes for multiple object hash
    else
      attribute_regexp = /\%([a-z0-9_]+).([a-z0-9_]+)\%/
      t = t.gsub(attribute_regexp) { |m| eval("object[:#{m[$1]}].#{m[$2]}") rescue nil}
    end
    prefix = nil; suffix = nil;
    
    return t
  end
  
  def parse(object, link = nil)
    TextTemplate.parse(body, object, link)
  end
  
  def <=>(o)
    name <=> o.name rescue 0
  end

  def title
    name.titleize
  end
  
  # Returns the text of this Template's body with parsable phrases highlighted.
  def highlighted_body(class_names = { :attributes => 'highlight', :conditionals => 'conditional highlight', :conditional_results => 'result highlight' })
    t = body.to_s.gsub(ATTRIBUTE_REGEXP) { |a| "<span class='#{class_names[:attributes]}'>#{a}</span>" }
    t = t.gsub(CONDITIONAL_REGEXP) { |c| "<span class='#{class_names[:conditional_results]}'><span class='#{class_names[:conditionals]}'><strong>IF</strong> #{c[$2]}:</span>#{c[$3]}</span>" }
  end
end