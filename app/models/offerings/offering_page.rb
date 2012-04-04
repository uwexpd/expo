# Each Offering organizes the application process into one or more pages.  This is also used when displaying the application details in an admin context.
class OfferingPage < ActiveRecord::Base
  stampable
  belongs_to :offering
  has_many :offering_questions, :order => "ordering", :dependent => :destroy
  has_many :questions, :class_name => "OfferingQuestion", :order => "ordering"

  acts_as_list :column => 'ordering', :scope => :offering
  
  validates_uniqueness_of :ordering, :scope => :offering_id

  def <=>(o)
    ordering <=> o.ordering rescue 0
  end

  def next
    self.offering.pages.find_by_ordering(self.ordering+1) or nil
  end

  def prev
    self.offering.pages.find_by_ordering(self.ordering-1) or nil
  end

  # If the +hide_in_admin_view+ boolean is set, then it is automatically hidden from reviewer view as well.
  def hide_in_reviewer_view?
    hide_in_admin_view? ? true : read_attribute(:hide_in_reviewer_view)
  end
  
end
