  # Allows program staff to specify the periods of time that are allowed for Interview time selection. Each OfferingInterviewTimeblock has a date, a start time and an end time. These periods of time will then be displayed to users when the input their interview time availability later.
class OfferingInterviewTimeblock < ActiveRecord::Base
  stampable
  belongs_to :offering
  

end
