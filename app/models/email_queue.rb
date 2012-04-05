class EmailQueue < ActiveRecord::Base
  stampable
  EmailQueue.partial_updates = false # disable partial_updates so that serialized columns get saved
  
  belongs_to :person
  serialize :email
  belongs_to :application_status
  belongs_to :original, :class_name => "ContactHistory", :foreign_key => "original_contact_history_id"

  belongs_to :contactable, :polymorphic => true
  
  # Adds a message to the queue.
  def self.queue(person, tmail_object, application_status = nil, command_after_delivery = nil, original_contact_history = nil, contactable = nil)
    EmailQueue.create :person_id => person, 
                      :email => tmail_object, 
                      :application_status_id =>  (application_status.nil? ? nil : application_status.id),
                      :command_after_delivery => command_after_delivery,
                      :original_contact_history_id => (original_contact_history.nil? ? nil : original_contact_history.id),
                      :contactable => (contactable.nil? ? nil : contactable)
  end
  
  # Returns true if there are messages waiting in the queue. This can be useful if you need to know if you should 
  # redirect a user to the email queue to handle messages. By default, this is based only on messages queued by the
  # current user. Pass ":all" as the first parameter to get all messages.
  def self.messages_waiting?(select = :current_user)
    EmailQueue.count(select) > 0
  end

  # Returns the number of messages in the queue. By default, this is based only on messages queued by the
  # current user. Pass ":all" as the first parameter to get all messages.
  def self.count(select = :current_user)
    EmailQueue.messages(select).size
  end

  # Returns the messages in the queue. By default, this is based only on messages queued by the
  # current user. Pass ":all" as the first parameter to get all messages.
  def self.messages(select = :current_user)
    conditions = (select == :current_user && User.current_user) ? { :creator_id => User.current_user.id } : { }
    EmailQueue.find(:all, :conditions => conditions)
  end
  
  # Returns the name of the person this email is being sent to, if available.
  def recipient_name
    person.nil? ? email.to.to_s : person.fullname
  end
  
  # Releases an email from the queue by sending the email and deleting this EmailQueue record. If a +command_after_delivery+ was specified
  # when this object was created, execute that command now as well.
  def release
    # person_id = person.nil? ? nil : person.id
    # application_status_id = application_status.nil? ? nil : application_status.id
    if @email_contact = EmailContact.log(person_id, ApplyMailer.deliver(email), application_status, original, contactable)
      begin
        eval(command_after_delivery) if command_after_delivery
        self.destroy
      rescue Exception => e
        self.update_attribute(:error_details, "The message was sent but the command after delivery was not executed: #{e.message}")
      end
    end
  end

end
