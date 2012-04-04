class SessionHistory < ActiveRecord::Base
  stampable
  belongs_to :login_history, :foreign_key => 'session_id'
  
  named_scope :old, lambda { { :conditions => ["created_at < ?", 1.month.ago] } }
  
end
