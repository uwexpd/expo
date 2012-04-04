class CommitteeMemberType < ActiveRecord::Base
  stampable
  belongs_to :committee
  validates_presence_of :name
  # Returns the +extra_instructions_link_text+ attribute, or the default if blank. Default is "Additional instructions"
  def extra_instructions_link_text
    read_attribute(:extra_instructions_link_text).blank? ? "Additional instructions" : read_attribute(:extra_instructions_link_text)
  end
end
