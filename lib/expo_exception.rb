class ExpoException < Exception

  attr_accessor :detail, :help_text
  
  def self.new(msg = nil, detail = nil, help_text = nil)
    e = super(msg)
    e.detail = detail
    e.help_text = help_text
    e
  end

end
