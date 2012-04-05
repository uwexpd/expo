class ContactType < ActiveRecord::Base
  stampable
  
  def <=>(o)
    title <=> o.title
  end
  
end
