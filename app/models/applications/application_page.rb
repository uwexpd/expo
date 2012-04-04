class ApplicationPage < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_page
  
  attr_accessor :ordering
  
  delegate :title, :hide_in_admin_view?, :hide_in_reviewer_view?, :to => :offering_page
  
  def ordering
    offering_page.ordering
  end

  def complete?
    return true if complete    
  end

  def passes_validations?
    offering_page.questions.each do |question|
      question.add_errors(self)
    end
    self.errors.empty?
  end
    
end
