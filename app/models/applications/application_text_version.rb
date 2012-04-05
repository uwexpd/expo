class ApplicationTextVersion < ActiveRecord::Base
  stampable
  
  validates_presence_of :application_text_id
  
  SANITIZE_REMOVE_STRINGS = ["class=\"MsoNormal\"", "<!--StartFragment-->", "<!--EndFragment-->", "<p ></p>", "<p>&nbsp;</p>"]
  
  # Overrides the setter method for +text+. We use this to clean up some annoying bits of HTML that might make it in from the user input.
  def text=(new_text)
    write_attribute(:text, ApplicationTextVersion.sanitize(new_text))
  end

  # Cleans up the text that's passed to it:
  # 
  # * Removes annoying text strings that muck up the works, as defined by +SANITIZE_REMOVE_STRINGS+
  # * Executes +strip+ on the result
  def self.sanitize(new_text)
    SANITIZE_REMOVE_STRINGS.each {|s| new_text = new_text.gsub(s, "")}
    new_text.strip
  end
  
end
