class GeneralStudyFaculty < ActiveRecord::Base
  validates_presence_of :firstname
  validates_presence_of :lastname
  validates_presence_of :code
end
