class ApplicationMentorType < ActiveRecord::Base
  stampable
  has_many :application_mentors

end
