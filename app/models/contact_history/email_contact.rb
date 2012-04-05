class EmailContact < ContactHistory
  stampable

  # Returns all EmailContacts that were sent to specified email address.
  # TODO This should be replaced with a named_scope at some point.
  def self.to_address(email_address)
    all(:order => 'updated_at DESC', :include => :person).select{|e| e.email.to.include?(email_address) rescue false }
  end

  def self.log(person, tmail_object, application_status = nil, original_contact_history = nil, contactable = nil)
    EmailContact.create :person_id => person, 
                        :email => tmail_object, 
                        :application_status_id => (application_status.nil? ? nil : application_status.id),
                        :original_contact_history_id => (original_contact_history.nil? ? nil : original_contact_history.id),
                        :contactable => (contactable.nil? ? nil : contactable)
  end
  
  # Creates a new email in the queue based on this EmailContact.
  def requeue
    EmailQueue.queue(person, email, application_status, nil, self, contactable)
  end
  
  
  
end
