class LoginHistory < ActiveRecord::Base
  stampable
  belongs_to :user
  # has_many :session_histories, :class_name => "SessionHistory", :primary_key => "session_id", :foreign_key => "session_id"
  
  # Logs a user's successful login action
  def self.login(user, ip = nil, session_id = nil)
    self.create(:user => user, :ip => ip, :session_id => session_id) if user.is_a?(User)
  end
  
  # Returns true if the user request was generated from an on-campus IP address. Obviously, this should not be trusted, but it
  # can be informational.
  def on_campus?
    %w(128.95 172.25 128.208 172.28 140.142 172.22).each do |subnet|
      return true if ip_in(subnet)
    end
    false
  end

  def session_histories
    SessionHistory.find(:all, :conditions => ['session_id = ?', session_id])
  end
  
  private
  
  # Returns true if the given IP address is within the given /24 subnet. This is a simple test that only compares the first
  # two octets using ==.
  def ip_in(subnet24)
    return false if ip.nil?
    ip.split(".")[0..1].join(".") == subnet24
  end
  
end
