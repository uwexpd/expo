class ApplicationCategory < ActiveRecord::Base
  stampable
  has_many :application_for_offerings
  
  def <=>(o)
    title <=> o.title rescue -1
  end
  
end
