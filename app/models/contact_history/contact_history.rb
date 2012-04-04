class ContactHistory < ActiveRecord::Base
  stampable
  ContactHistory.partial_updates = false  # disable partial_updates so that serialized columns get saved
  
  belongs_to :person
  belongs_to :application_status
  belongs_to :original, :class_name => "ContactHistory", :foreign_key => "original_contact_history_id"
  has_many :related_messages, :class_name => "ContactHistory", :foreign_key => "original_contact_history_id"
  serialize :email

  belongs_to :contactable, :polymorphic => true

  named_scope :to_person, lambda { |person_id| { :conditions => ['person_id = ?', person_id] }}
  named_scope :from_user, lambda { |user_id| { :conditions => ['creator_id = ?', user_id] }}


  # TODO Determines whether or not this user can see this contact history or not.
  def allows?(obj)
    true
  end

end
