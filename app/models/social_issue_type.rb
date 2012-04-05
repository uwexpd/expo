class SocialIssueType < ActiveRecord::Base
  stampable
  validates_presence_of :title
  
end
