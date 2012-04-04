# Used for storing bits of help text in the database so that admin users can control it without changing code.
# 
# ModelHelpTexts can be connected to a model and attribute; plain HelpTexts are simply defined with a unique key.
class HelpText < ActiveRecord::Base
  stampable
  validates_presence_of :key, :unless => Proc.new { |t| t.is_a?(ModelHelpText) }
  validates_uniqueness_of :key, :scope => :object_type, :unless => Proc.new { |t| t.is_a?(ModelHelpText) }
  
  # Returns the caption for the HelpText with the specified key and object type. Object type is optional.
  def self.caption(key, object_type = nil)
    ht = HelpText.find_by_key_and_object_type(key.to_s, object_type.to_s)
    return nil if ht.nil?
    ht.caption
  end
  
end
