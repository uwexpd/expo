# An ApplicationForOffering object is a representation of a person's application for a specific Offering managed by EXPo
# (The model is named _ApplicationForOffering_ not only to be descriptive but also to avoid Rails' limitations on the reserved word
# _application_.  Related models begin only with Application for brevity).
class ApplicationForOffering < ActiveRecord::Base
  stampable
  include ActionController::UrlWriter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper
  include Comparable
  acts_as_soft_deletable

  belongs_to :offering, :counter_cache => true
  belongs_to :person
  belongs_to :current_page, :class_name => "ApplicationPage", :foreign_key => "current_page_id"
  
  has_one :offering_invitation_code

  has_many :answers, :class_name => "ApplicationAnswer", :dependent => :destroy
  has_many :awards, :class_name => "ApplicationAward", :dependent => :destroy do
    def valid
      find(:all, :conditions => 'requested_quarter_id is not null')
    end
  end
  has_many :files, :class_name => "ApplicationFile", :dependent => :destroy
  has_many :notes, :as => "notable", :dependent => :destroy
  has_many :texts, :class_name => "ApplicationText", :dependent => :destroy
  # has_many :interviewers, :class_name => "ApplicationInterviewer", :dependent => :destroy
  has_many :mentors, :class_name => "ApplicationMentor", :dependent => :destroy
  belongs_to :nominated_mentor, :class_name => "ApplicationMentor", :foreign_key => "nominated_mentor_id"
  has_many :other_awards, :class_name => "ApplicationOtherAward", :dependent => :destroy
  has_many :pages, :class_name => "ApplicationPage", :dependent => :destroy
  has_many :reviewers, :class_name => "ApplicationReviewer", :include => :scores, :dependent => :destroy do
    def without_committee_scores; find(:all, :conditions => "committee_score IS NULL OR committee_score = 0"); end;
  end
  has_many :application_statuses, :dependent => :destroy
  has_many :statuses, :class_name => "ApplicationStatus", :dependent => :destroy
  has_many :group_members, :class_name => "ApplicationGroupMember", :dependent => :destroy do
    def valid; all.select{|m| !m.new_record? || m.valid? }; end
    def verified; all.select{|m| m.verified? }; end
  end
  has_many :guests, :class_name => "ApplicationGuest", :foreign_key => "application_for_offering_id"
  belongs_to :current_application_status, :class_name => "ApplicationStatus", :foreign_key => "current_application_status_id"
  belongs_to :application_review_decision_type
  belongs_to :application_interview_decision_type
  belongs_to :application_moderator_decision_type
  belongs_to :application_final_decision_type
  belongs_to :feedback_person, :class_name => "ApplicationReviewer", :foreign_key => "feedback_person_id"
  belongs_to :feedback_meeting_person, :class_name => "Person", :foreign_key => "feedback_meeting_person_id"
  belongs_to :interview_feedback_person, :class_name => "OfferingInterviewInterviewer", :foreign_key => "interview_feedback_person_id"
  belongs_to :application_type, :class_name => "OfferingApplicationType", :foreign_key => "application_type_id"
  belongs_to :application_category, :class_name => "OfferingApplicationCategory", :foreign_key => "application_category_id"
  belongs_to :offering_session, :class_name => "OfferingSession", :foreign_key => "offering_session_id"
  belongs_to :location_section, :class_name => "OfferingLocationSection", :foreign_key => "location_section_id"
  has_many :interview_availabilities
  has_many :offering_interview_applicants
  has_many :offering_interviews, :through => :offering_interview_applicants
  has_many :event_invitees, :include => {:event_time => :event}, :as => 'invitable' do
    def for_event(event); find(:all).select{|e| e.event == event }; end
  end
  
  serialize :task_completion_status_cache
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!
  
  attr_protected :offering_id, :person_id
  
  attr_accessor :new_status_note
  attr_accessor :skip_validations
  attr_accessor :require_moderator_comments
  
  after_create :build_pages, :build_awards, :build_files, :build_mentors
  after_update :save_person, :save_other_awards, :save_awards, :save_files, :save_mentors, :save_group_members
  before_save :check_validity_of_application_category
  before_save :update_offering_session_counts
  
  validates_associated :other_awards
  validates_presence_of :offering_id, :person_id

  validates_uniqueness_of :easel_number, :scope => [ :offering_id, :offering_session_id, :location_section_id ], :allow_nil => true
  
  validates_presence_of :moderator_comments, :if => :require_moderator_comments?
  def require_moderator_comments?
    return false if application_moderator_decision_type.nil?
    require_moderator_comments && !application_moderator_decision_type.yes_option
  end

  attr_accessor :validate_nominated_mentor
  validate :nominated_mentor_explanation_length, :if => :validate_nominated_mentor?
  validates_presence_of :nominated_mentor_id, :nominated_mentor_explanation, :if => :validate_nominated_mentor?
  def validate_nominated_mentor?; validate_nominated_mentor; end
  def nominated_mentor_explanation_length
    if nominated_mentor_explanation.split.size > 200
      overage = nominated_mentor_explanation.split.size - 200
      errors.add(:nominated_mentor_explanation, "must be less than 200 words. You need to remove #{overage} words.")
    end
  end

  attr_accessor :validate_theme_responses
  validate :theme_responses_validation, :if => :validate_theme_responses?
  def validate_theme_responses?; validate_theme_responses; end;
  def theme_responses_validation
    if theme_response.split.size > offering.theme_response_word_limit
      overage = theme_response.split.size - offering.theme_response_word_limit
      errors.add(:theme_response, "must be less than #{offering.theme_response_word_limit} words. You need to remove #{overage} words.")
    end
    if !offering.theme_response2_instructions.blank? && theme_response2.split.size > offering.theme_response2_word_limit
      overage = theme_response2.split.size - offering.theme_response2_word_limit
      errors.add(:theme_response2, "must be less than #{offering.theme_response2_word_limit} words. You need to remove #{overage} words.")
    end
  end

  PLACEHOLDER_CODES = %w(login_link admin_link project_title stripped_project_title project_description easel_number mentor_department
                        current_status_name status_sequence submitted? award_list total_requested_award_amount mentor_letter_received?
                        all_mentor_letters_received? mentors_list review_committee_decision interview_committee_decision
                        final_committee_decision
                        awarded? dean_approved? financial_aid_approved? disbursed? includes_contingency? invited_for_interview? average_score
                        score_standard_deviation score_spread weighted_combined_score address_for_print application_category_title )
  PLACEHOLDER_ASSOCIATIONS = %w(person offering primary_mentor offering_session location_section application_type)
#  EMAIL_RECIPIENT_CHOICES = { :applicant => self, :mentors => mentors }
  
  # Returns the current status of this application.  If the application has not yet been assigned a status, this method will
  # set the status as new.
  def status(set_blank_to_new = true)
    return current_status || (self.set_status('new') if set_blank_to_new)
  end
  
  def person_name
    person.fullname
  end
  
  delegate :fullname, :lastname_first, :firstname_first, :to => :person
  
  # Checks if the number of reviewers assigned to this application are enough to satisfy the +min_number_of_reviews_per_applicant+
  # flag in the Offering.
  def reviewers_full?
    return false if offering.min_number_of_reviews_per_applicant.blank?
    reviewers.without_committee_scores.size >= offering.min_number_of_reviews_per_applicant
  end
    
  def current_status
    # self.application_statuses.find :first, :order => 'updated_at DESC'
    if current_application_status.nil?
      search_result = self.application_statuses.find(:first, :order => 'updated_at DESC')
      update_attribute(:current_application_status_id, search_result.id) unless search_result.nil?
      return search_result
    else
      return current_application_status
    end
  end
  
  def current_status_name
    current_status.nil? ? nil : current_status.name
  end
  
  def in_status?(name)
    current_status_name == name.to_s
  end

  # Returns true if this application's status is anything but new, in_progress, cancelled, or not_awarded_not_submitted.
  def submitted?
    nonsubmitted_statuses = %w(new in_progress cancelled not_awarded_not_submitted)
    !current_status.nil? && !nonsubmitted_statuses.include?(current_status.name)
  end
  
  def user_editable?
    status.offering_status.nil? ? false : !status.offering_status.disallow_user_edits
  end
  
  def award_list(delimiter = ", ", include_amount = true)
    awards_formatted = Array.new
    awards.valid.each do |a|
      str = "#{a.requested_quarter.title}"
      str << ": #{number_to_currency(a.amount_requested)}" if include_amount
      str << " (Awarded #{number_to_currency(a.amount_awarded)})" if include_amount && !a.amount_awarded.blank?
      awards_formatted << str
    end
    awards_formatted.join(delimiter)
  end
  
  # Returns the sum of all requested awards in Numeric format. If you want a printable list of the awards, use award_list.
  def total_requested_award_amount
    total = 0.0
    awards.valid.each do |a|
      total += a.amount_awarded.blank? ? a.amount_requested : a.amount_awarded
    end
    total
  end
  
  # Sets the status of this application based on a name value (which is a unique key in the ApplicationStatusType model)
  # and return the ApplicationStatus object of the new status.
  # * If the ApplicationStatusType doesn't already exist, we create it.  Otherwise, just find that type.
  # * If this is already the current status type for this app, then we simply update the +updated_at+.
  # * If the option +force+ is set to +true+, then we actually create a new ApplicationStatus record. This allows us to
  #   re-assign the current status to this application so that we can resend the status update emails, for instance.
  # Otherwise, add this type to the list of statuses for this application and make it current.
  def set_status(name, deliver_emails_now = true, options = {})
    name = name.to_s if name.is_a?(Symbol)
    @type = ApplicationStatusType.find_or_create_by_name(name)
    @status = self.application_statuses.find_by_application_status_type_id(@type, :order => 'updated_at DESC')
    if @status.nil? || @status != self.current_status || options[:force] == true
      @status = self.application_statuses.create :application_status_type_id => @type.id
      @status.update_attribute(:note, options[:note]) unless options[:note].blank?
      self.save; self.reload
      self.send_status_updates(@status, deliver_emails_now)
    end
    update_attribute(:current_application_status_id, @status.id)
    self.status
  end
  
  def new_status
    
  end
  
  # Handles the +dynamic_answer_:id+ methods for getting and setting dynamic ApplicationAnswer associations.
  def method_missing(method_name, *args)
    match = method_name.to_s.match(/dynamic_answer_(\d+)(=?)/)
    if match
      match[2] == "=" ? set_answer(match[1], args.first) : get_answer(match[1])
    else
      super
    end
  end
  
  # Returns an applicant's answer to the specified question. This only works for questions that are marked as +dynamic_answer = true+.
  # This method also defines a new setter method for the dynamic_answer_:id structure so that we can update the dynamic answer
  # using mass assignment. This means that we MUST call this getter method _before_ we try to set the method using mass assignment.
  def get_answer(offering_question_id, offering_question_option_id=nil)
    question = offering.questions.find(offering_question_id)
    if offering_question_option_id.nil? && !question.display_as.include?("checkbox_options")
      answer = answers.find_or_create_by_offering_question_id(offering_question_id).answer
      self.class.send :define_method, "dynamic_answer_#{offering_question_id.to_s}=", Proc.new {|argv| set_answer(offering_question_id, argv)}
    else
      option_answer = answers.find_by_offering_question_option_id(offering_question_option_id)
      answer = option_answer.nil? ? "false" : option_answer.answer
      self.class.send :define_method, "dynamic_answer_#{offering_question_id.to_s}_#{offering_question_option_id.to_s}=",
                                             Proc.new {|argv| set_answer(offering_question_id, argv, offering_question_option_id)}
    end    
    type_cast_dynamic_answer(answer)
  end
    
  # Save the answer to the specified question. Note that if +display_as=checkbox_options+, use +offering_question_option_id+ to save checked question_option_id.
  def set_answer(offering_question_id, answer, offering_question_option_id=nil)
    question = offering.questions.find(offering_question_id)
    if offering_question_option_id.nil?
      if question.display_as.include?("date")
        if answer["year"].empty? || answer["month"].empty? || answer["day"].empty?
          answer = nil
        else
          answer = answer["year"]+"-"+answer["month"]+"-"+answer["day"]
        end
      end      
      answers.find_or_create_by_offering_question_id(offering_question_id).update_attribute(:answer, answer)
    else
      option_answer = answers.find_or_create_by_offering_question_option_id(offering_question_option_id)
      option_answer.update_attribute(:answer, answer)
      option_answer.update_attribute(:offering_question_id, offering_question_id)
    end    
  end
  

  # Tries to type cast the dynamic answer that's returned from the DB, which is stored as a string.
  # 
  # * "true" or "false" gets cast to +true+ and +false+
  # * numbers with no decimal points get converted to int
  # * numbers with decimal points get converted to float
  def type_cast_dynamic_answer(answer)
    if answer.nil?
      nil
    elsif answer == "true"
      true
    elsif answer == "false"
      false
    elsif answer.match /^\d+$/
      answer.to_i
    elsif answer.match /^\d+.\d+$/
      answer.to_f
    else
      answer
    end
  end

  # Overrides the default #attributes= method to first call #define_dynamic_answer_setters! so that our dynamic answers
  # can be set with mass assignment without having to change our controller behaviors and do something special on every save.
  def attributes=(*args)
    define_dynamic_answer_setters!
    super(*args)
  end
  
  def new_reviewer
    
  end
  
  def remove_reviewer
    
  end
  
  def new_reviewer=(reviewer)
    reviewer = CommitteeMember.find(reviewer) unless offering.review_committee.nil?
    add_reviewer(reviewer)
  end
  
  def remove_reviewer=(reviewer)
    reviewer = CommitteeMember.find(reviewer)
    drop_reviewer(reviewer)
  end
  
  # Adds an ApplicationReviewer to this application as a reviewer. Parameter can be either an OfferingReviewer ID or a CommitteeMember object.
  def add_reviewer(reviewer)
    if reviewer.is_a?(Integer)
      self.reviewers.create :offering_reviewer_id => reviewer
    elsif reviewer.is_a?(CommitteeMember)
      return false if (mentors.collect(&:person_id).include?(reviewer.person_id) unless offering.allow_to_review_mentee) && !reviewer.person_id.nil?
      self.reviewers.create :committee_member_id => reviewer.id
    end
    self.save
  end
  
  # Drops an ApplicationReviewer from this application. Parameter can be either an OfferingReviewer ID or a CommitteeMember object.
  def drop_reviewer(reviewer)
    if reviewer.is_a?(Integer)
      r = reviewers.find_by_offering_reviewer_id(reviewer)
    elsif reviewer.is_a?(CommitteeMember)  
      r = reviewers.find_by_committee_member_id(reviewer.id)
    end
    r.destroy
    self.save
  end
  
  # Returns an array of the Review Committee Members who are *not* assigned to this applicant. Useful for assigning reviewers.
  def unassigned_review_committee_members
    offering.review_committee.members - reviewers.collect{|r| r.committee_member rescue nil}
  end
  
  def send_status_updates(status = self.status, deliver_emails_now = true)
    if status.offering_status && !status.offering_status.emails.nil?
      status.offering_status.emails.each do |email|
        send_status_update(email, deliver_emails_now, status)
      end
    end
  end

  # Sends status update to applicants, staff, mentors, and verified group members.
  def send_status_update(email, deliver_emails_now = true, status = nil)
    if email.send_to == "applicant"
      cc_to_feedback_person = email.cc_to_feedback_person?
      email_object = ApplyMailer.create_status_update(self, email.email_template, self.person.email, Time.now, 
                                                      apply_url(:host => CONSTANTS[:base_url_host], 
                                                                :offering => offering),
                                                      apply_url(:host => CONSTANTS[:base_url_host], 
                                                                :offering => offering) + "/availability",
                                                      cc_to_feedback_person)
      if deliver_emails_now
        EmailContact.log self.person.id, ApplyMailer.deliver(email_object), status
      else
        EmailQueue.queue self.person.id, email_object, status
      end
    elsif email.send_to == "staff"
      if deliver_emails_now
        ApplyMailer.deliver_status_update(self, email.email_template, self.offering.notify_email || self.offering.contact_email) # don't log messages to staff
      end
    elsif email.send_to == "group_members"
      self.group_members.verified.each do |group_member|
        group_member.reload
        self.send_group_member_status_update(group_member, email, deliver_emails_now, status)
      end
    elsif email.send_to == "mentors"
      self.mentors.each do |mentor|
        mentor.reload
        unless (mentor.letter_received? && status.name == "submitted") || mentor.invite_email_sent? # don't send the "please submit a letter" email if submitted
          if mentor.no_email
            ApplyMailer.deliver_mentor_no_email_warning(mentor, self.offering.notify_email)
          else
            self.send_mentor_status_update(mentor,email, deliver_emails_now, status)
          end
        end
      end
    end
  end

  def send_email(email_template_id, deliver_emails_now = true, send_to = "applicant")    
    if send_to == "mentors"
      self.mentors.each do |mentor|
        unless mentor.no_email
          EmailQueue.queue mentor.person_id, ApplyMailer.create_mentor_status_update(mentor, EmailTemplate.find(email_template_id), mentor.email)
        end
      end
    else
      EmailQueue.queue self.person.id, ApplyMailer.create_status_update(self, EmailTemplate.find(email_template_id), self.person.email)
    end
  end

  # Sends status update to mentor
  def send_mentor_status_update(mentor, email, deliver_emails_now = true, status = nil)
    link = mentor_offering_map_url(:host => CONSTANTS[:base_url_host], :offering_id => offering.id, :mentor_id => mentor.id, :token => mentor.token)
    if deliver_emails_now
      EmailContact.log mentor.person_id, ApplyMailer.deliver_mentor_status_update(mentor, email.email_template, mentor.email, nil, link), status
    else
      EmailQueue.queue mentor.person_id, ApplyMailer.create_mentor_status_update(mentor, email.email_template, mentor.email, nil, link), status
    end
  end
  
  # Sends status update to group member
  def send_group_member_status_update(group_member, email, deliver_emails_now = true, status = nil)
    link = apply_url(:host => CONSTANTS[:base_url_host], :offering => offering)
    if deliver_emails_now
      EmailContact.log group_member.person_id, ApplyMailer.deliver_group_member_status_update(group_member, email.email_template, group_member.email, nil, link), status
    else
      EmailQueue.queue group_member.person_id, ApplyMailer.create_group_member_status_update(group_member, email.email_template, group_member.email, nil, link), status
    end
  end
  
  # def create_mentor_user_and_send_email(mentor,email)
  #   p = Person.find_by_email(mentor.email)
  #   if p.nil?
  #     p = Person.create(:email => mentor.email, :firstname => mentor.firstname, :lastname => mentor.lastname)
  #   end
  #   mentor.person = p; mentor.save
  #   if User.find_by_person_id(mentor.person.id).nil?
  #     # this is a new user
  #     link = mentor_url(:host => CONSTANTS[:base_url_host], :pid => mentor.person.id, :token => mentor.person.token)
  #   else
  #     link = mentor_url(:host => CONSTANTS[:base_url_host])
  #   end
  #   EmailContact.log mentor.person.id, ApplyMailer.deliver_mentor_status_update(mentor, email.email_template, mentor.email, nil, link)
  # end

  def save_person
    person.save(false)
  end

  def extra_attributes=(extra_attributes)
    extra_attributes['person'].each do |attributes|
      person.attributes = attributes[1]
    end
  end

  # Text_attributes should use the title of the text as the key.
  def texts_attributes=(texts_attributes)
    texts_attributes.each do |text_title, attributes|
      text(text_title).update_attributes(attributes)
    end
  end

  # Other_award_attributes should be form-encoded in the following structure:
  # :offering_other_award_type_id => { "secured" => "1", "award_quarter_id" => ":award_quarter_id"}
  # For every element in other_award_attributes, this method looks to see if "secured" is true. If so, we make sure that a
  # corresponding +other_award+ object exists or gets created, then update the award_quarter_id. If "secured" is false or nil, then
  # we know to delete the corresponding other_award record (for now, we don't care about non-secured awards).
  def other_award_attributes=(other_award_attributes)
    other_award_attributes.each do |offering_other_award_type_id, ow_attributes|
      if ow_attributes[:secured] == "1"
        n = other_awards.find_or_create_by_offering_other_award_type_id(offering_other_award_type_id)
        n.update_attributes(ow_attributes)
      else
        d = other_awards.find_by_offering_other_award_type_id(offering_other_award_type_id)
        other_awards.delete(d) if d
      end
    end
  end

  def mentor_attributes=(mentor_attributes)
    mentor_attributes.each do |mentor_id, attributes|
      # if attributes[:id].blank?
      #   mentors.build(attributes)
      # else
        mentor = mentors.detect { |m| m.id == mentor_id.to_i }
        mentor.attributes = attributes
        mentor.update_attribute(:email, attributes[:email].strip) unless attributes[:email].blank? 
        mentor.update_attribute(:email_confirmation, attributes[:email_confirmation].strip) unless attributes[:email_confirmation].blank? 
      # end
    end
  end
  
  def group_member_attributes=(group_member_attributes)
    group_member_attributes.each do |group_member_id, attributes|
      if attributes[:id].blank?
        group_members.build(attributes)
      else
        group_member = group_members.detect { |m| m.id == group_member_id.to_i }
        group_member.attributes = attributes
      end
    end
  end
  
  def save_other_awards
    other_awards.each do |a|
      if a.should_destroy?
        a.destroy
      else
        a.save(false)
      end
    end
  end
  
  def save_mentors
    mentors.each do |m|
      if m.should_destroy?
        m.destroy
      else
        m.save(false)
      end
    end
  end
  
  def save_group_members
    group_members.each do |m|
      # if m.should_destroy?
      #   m.destroy
      # else
        m.save(false)
      # end
    end
  end
  
  def other_awards?
    !other_awards.size.zero?
  end

  def save_awards
    awards.each do |a|
      if a.should_destroy?
        a.destroy
      else
        a.save(false)
      end
    end
  end
  
  def save_files
    files.each do |f|
      f.save(false)
#      f.convert_to_pdf unless f.file.mime_type == 'application/pdf'
    end
  end
  
  def award_attributes=(award_attributes)
    award_attributes.each do |attributes|
      award = awards.detect { |a| a.id == attributes[:id].to_i }
      award.attributes = attributes
    end
  end

  def file_attributes=(file_attributes)
    file_attributes.each do |file_id, attributes|
      if file_id.blank? || file_id.to_i == 0
        files.build(attributes)
      else
        file = files.detect { |f| f.id == file_id.to_i }        
        file.attributes = attributes  
      end
    end
  end
    
  def build_pages
    offering.pages.each do |page|
      pages.build :application_for_offering_id => id, :offering_page_id => page.id
    end
  end

  def start_page(page)
    application_page = pages.find_by_offering_page_id(page)
    application_page.started = true
    application_page.save; application_page.reload
    self.current_page_id = application_page.id
    self.save; self.reload
  end
  
  # def run_page_validations(page)
  #   application_page = pages.find_by_offering_page_id(page)
  #   if application_page.started
  #     if !self.page_passes_validations?(self.current_page)
  #       #self.errors.on_base.clear unless self.errors.on_base.nil?
  #     end
  #   end
  # end
  # 
  def passes_validations?
    return true if skip_validations
    result = true
    pages.each do |page|
      result = false unless page.passes_validations?
    end
    result
  end
  
  
  def page_passes_validations?(offering_page_id)
    page = ApplicationPage.find_by_offering_page_id_and_application_for_offering_id(offering_page_id, self.id)
    page.passes_validations?
  end
  
  def electronic_signature_valid?
    !electronic_signature.blank?
  end
  
  # def page_passes_validations?(page)
  #   page.offering_page.questions.each do |question|
  #     if !question.passes_validations?(self)
  #       self.errors.add_to_base question.error_message
  #       self.errors.add question.attribute_to_update
  #     end
  #   end
  #   self.errors.empty?
  # end
  
  # def add_validation_error(attribute, error_text)
  #   self.errors.add_to_base "bad"
  # end

  def build_awards
    offering.number_of_awards.to_i.times { self.awards.build :amount_requested => offering.default_award_amount }
  end

  def build_files
    offering.questions.find(:all, :conditions => "display_as = 'files'").each do |q|
      self.files.build :offering_question_id => q.id, :title => q.short_question_title
    end
    self.save
  end
  
  def build_mentors
    offering.min_number_of_mentors.to_i.times { self.mentors.create(:primary => true) }
  end
  
  # Returns true if the current number of mentors created for this application is still less than the +max_number_of_mentors+ 
  # for this Offering.
  def more_mentors_ok?
    mentors.size < offering.max_number_of_mentors
  end
  
  # Returns false if removing a mentor would bring the total number of mentors for this application below the +min_number_of_mentors+
  # for this Offering.
  def less_mentors_ok?
    mentors.size > offering.min_number_of_mentors
  end
  
  
  # Offerings can include a "minimum qualification" for mentors, based on mentor type. This method returns true if any of
  # the mentors attached to this application meet the minimum qualification or not. (Used in validation).
  def mentors_meet_minimum_qualification?
    mentors.collect(&:meets_minimum_qualification?).include?(true)
  end

  # Returns true if at least one mentor letter has been received for this application.
  def mentor_letter_received?
    letter_received = false
    mentors.each do |m|
      letter_received = true unless m.letter.nil?
    end
    return letter_received
  end

  # Returns true if all mentor letters have been received
  def all_mentor_letters_received?
    mentors.each do |m|
      return false if m.letter.nil?
    end
    true
  end

  # Returns the sequence of the current application status. This sequence is unique to this application's Offering.
  def status_sequence
    (current_status.nil? || current_status.sequence.nil?) ? 0 : current_status.sequence
  end

  # Returns true if this application was ever in the status requested. By default, this will NOT include applications
  # that are currently cancelled, unless you pass +true+ as the second parameter.
  # Note that this method respects the status "sequence." If you want to disregard status sequence, try #includes_status?.
  def passed_status?(s, include_cancelled = false, respect_sequence = true)
    return false if in_status?(:cancelled) && !include_cancelled
    s = s.to_s if s.is_a?(Symbol)
    if respect_sequence
      offering_status = offering.statuses.find(:first, 
        :joins => :application_status_type, 
        :conditions => { "application_status_types.name" => s})
      return false if offering_status && status_sequence < offering_status.sequence
    end
    statuses.collect(&:name).include?(s)
  end
  
  # Same as #passed_status? but respects status sequence.
  def includes_status?(s, include_cancelled = false)
    passed_status?(s, include_cancelled, false)
  end

  # Overrides Comparable to sort ApplicationForOfferings by 1) status_sequence and 2) student's fullname.
  def <=>(o)

    # Return "less than" if status type is nil
    return -1 if current_status.nil?

    # Compare status sequence first
   status_sequence_cmp = status_sequence <=> o.status_sequence
   return status_sequence_cmp unless status_sequence_cmp == 0

    # Compare status type name next
    status_type_cmp = current_status_name.to_s <=> o.current_status_name.to_s
    return status_type_cmp unless status_type_cmp == 0

    # Finally, compare full name
    fullname_cmp = person.lastname_first <=> o.person.lastname_first
    return fullname_cmp unless fullname_cmp == 0
    
    # Just in case we get to here, compare IDs
    return id <=> o.id
    
  end
  
  # Returns a comma-separated list of mentors for this application
  def mentors_list(delimiter = '; ')
    mentors.collect { |m| m.info_detail_line }.join(delimiter)
  end
  
  # Return the review committee's decision in a printable format
  def review_committee_decision
    application_review_decision_type.title if application_review_decision_type
  end

  # Returns the interview committee's decision in a printable format
  def interview_committee_decision
    application_interview_decision_type.title if application_interview_decision_type
  end

  # Return the final committee's decision in a printable format
  def final_committee_decision
    application_final_decision_type.title if application_final_decision_type
  end
  
  # Returns true if the interview_committee_decision was "Yes" or some other Yes Option (e.g., "Yes with Contingency")
  def awarded_by_interview_committee?
    application_interview_decision_type.nil? ? false : application_interview_decision_type.yes_option
  end

  # Returns true if the review_committee_decision was "Yes" or some other Yes Option (e.g., "Yes with Contingency")
  def awarded_by_review_committee?
    application_review_decision_type.nil? ? false : application_review_decision_type.yes_option
  end

  # Returns true if the final_committee_decision was "Yes" or some other Yes Option (e.g., "Yes with Contingency")
  def awarded_by_final_committee?
    application_final_decision_type.nil? ? false : application_final_decision_type.yes_option
  end

  # Returns true if this student was awarded or not. Depending on the value of Offering#award_basis, this method
  # checks either the #awarded_by_review_committee?, #awarded_by_interview_committee? or #awarded_by_final_committee?
  # method to determine the value to return. If Offering#award_basis is blank, then we default to using the review committee.
  def awarded?
    return false if declined?
    case offering.award_basis
    when "review"     then awarded_by_review_committee?
    when "interview"  then awarded_by_interview_committee?
    when "final"      then awarded_by_final_committee?
    else awarded_by_review_committee?
    end
  end

  # Returns true if this student's award was approved by the dean. This is based on the +approved_at+ date.
  def dean_approved?
    !approved_at.blank?
  end

  # For each valid award, copy the +amount_requested+ over to +amount_awarded+ unless there is already a value in
  # +amount_awarded+. If there is a value in +amount_awarded+, this means that the award committee decided (for whatever reason)
  # that the student should actually receive a different amount than requested. In this case, the dean is simply approving that change.
  # If +amount_awarded+ is blank, however, it means that we're giving the full requested amount so we should copy over the requested
  # amount into the awarded amount field. Note that you must also pass the User that made the approval.
  def dean_approve_awards(user)
    for award in awards.valid
      award.update_attribute(:amount_awarded, award.amount_requested) if award.amount_awarded.blank?
      award.update_attribute(:amount_awarded_user_id, user.id)
    end
    update_attribute(:approved_at, Time.now)
  end

  # Returns true if this student's award was approved by financial aid. This is based on the +financial_aid_approved_at+ date.
  def financial_aid_approved?
    !financial_aid_approved_at.blank?
  end

  # Returns true if this student's award was disbursed. This is based on the +disbursed_at+ date.
  def disbursed?
    !disbursed_at.blank?
  end

  # Returns true if this student's award process has been closed, meaning that no further action is required for this award. 
  # This is based on the +closed_at+ date.
  def closed?
    !closed_at.blank?
  end

  # Returns true if there is a contingency attached to this student's award.
  def includes_contingency?
    application_interview_decision_type.nil? ? false : application_interview_decision_type.contingency_option
  end

  # Returns true if the review committee decision has been input for this ApplicationForOffering. This is used to determine how to display some of the content on the Reviewer interface.
  def reviewed?
    !application_review_decision_type.nil?
  end
  
  # Returns true if the interview committee decision has been input for this ApplicationForOffering. This is used to determine how to display some of the content on the Interviewer interface.
  def interview_decision_made?
    !application_interview_decision_type.nil?
  end
  
  # Returns true if the applicant has identified themselves as being available for an interview at a certain time
  def available_for_interview?(time, timeblock)
    !interview_availabilities.find_by_time_and_offering_interview_timeblock_id(time.to_time, timeblock).nil?
  end

  # Returns true if the applicant was selected to move on past the review stage
  def invited_for_interview?
    if offering.uses_interviews?
      application_review_decision_type.nil? ? false : application_review_decision_type.yes_option
    else
      false
    end
  end

  def interview_time
    offering_interviews.first
  end
  
  def interview
    interview_time
  end

  def interviewers
    interview.nil? ? [] : interview.interviewers
  end

  def interview_time_passed?
    interview.time_passed? unless !interview
  end

  # Returns true if this student has submitted any times of availability. It's possible that this person has
  # gone in and left because they weren't available for _any_ times, and this method will still return false.
  def responded_with_availability?
    !interview_availabilities.empty?
  end

  # Returns an array of previous applications from this student that meet these conditions:
  # 
  # * The application passed the "complete" status
  # * The application is from an offering that matches one of the +other_award_type+s defined for this application's offering.
  # * The application is not this application.
  # 
  # This is used for the review process.
  def past_applications
    return [] if offering.other_award_types.empty?
    offerings_to_include = offering.other_award_types.collect(&:offerings).flatten.uniq.compact
    conditions = "offering_id IN (#{offerings_to_include.collect(&:id).join(",")}) && offering_id != #{offering_id}"
    all = person.application_for_offerings.find(:all, :conditions => conditions, :include => :statuses)
    all.select{|a| a.passed_status?(:complete) rescue false}
  end

  # Returns this application's feedback person. This method looks for an interview feedback person first, then a regular review 
  # feedback person, then returns nil if neither exists. In either case, a Person object (or nil) will be returned.
  def final_feedback_person
    return interview_feedback_person.person unless interview_feedback_person.nil?
    return feedback_person.person unless feedback_person.nil?
    nil
  end

  # Calculates the average score that this application recieved. If an OfferingReviewCriterion is passed, this is the average
  # of the scores for that criterion. Otherwise, returns the total average score based on the total_score of each ApplicationReviewer
  # (if the score was greater than zero). 
  # Only used for Offerings that use a scored review process.
  def average_score(review_criterion = nil)
    return reviewers.without_committee_scores.collect{|r| r.get_score(review_criterion)}.compact.reject{|s| s.zero?}.average unless review_criterion.nil?
    @average_score ||= reviewers.without_committee_scores.collect(&:total_score).compact.reject{|s| s.zero?}.average
  end

  # Calculates the standard deviation of the scores of this application's ApplicationReviewers by default, or of this
  # application's interviewers if you pass ":interviewers => true".
  # Only used for Offerings that use a scored review process.
  def score_standard_deviation(options = {})
    if options[:interviewers]
      interviewers.find(:all, :conditions => { :committee_score => false }).collect(&:total_score).compact.reject{|s| s.zero?}.standard_deviation rescue 0.0/0.0
    else
      reviewers.without_committee_scores.collect(&:total_score).compact.reject{|s| s.zero?}.standard_deviation rescue 0.0/0.0
    end
  end
  
  # Calculates the spread of the non-zero scores of this application's ApplicationReviewers by default, 
  # or of this application's interviewers if you pass ":interviewers => true". 
  # Only used for Offerings that use a scored review process.
  def score_spread(options = {})
    if options[:interviewers]
      interviewers.find(:all, :conditions => { :committee_score => false }).collect(&:total_score).compact.reject{|s| s.zero?}.spread rescue 0.0/0.0
    else
      reviewers.without_committee_scores.collect(&:total_score).compact.reject{|s| s.zero?}.spread rescue 0.0/0.0
    end
  end

  # Calculates the average between the reviewer committee and interview committee scores, based on the weight ratio defined
  # in Offering#final_decision_weight_ratio. If either committee score returns a nil, this method returns NaN.
  def weighted_combined_score
    return 0.0/0.0 if review_committee_score.nil? || interview_committee_score.nil?
    ratio = offering.final_decision_weight_ratio
    r = review_committee_score * ratio
    i = interview_committee_score * (1 - ratio)
    r + i
  end

  # Returns the review committee score.
  def review_committee_score
    review_committee_score_object.total_score rescue nil
  end

  # Returns the ApplicationReviewer object that contains the review committee's score.
  def review_committee_score_object
    reviewers.find(:first, :conditions => { :committee_score => true }) rescue nil
  end
  
  # Returns the interview committee score.
  def interview_committee_score
    interview_committee_score_object.total_score rescue nil
  end

  # Returns the OfferingInterviewer object that contains the interview committee's score.
  def interview_committee_score_object
    interviewers.find(:first, :conditions => { :committee_score => true }) rescue nil
  end  
  
  # Returns this student's mailing address based on the selection of local or permanent address during the application process.
  def address_for_print(separator = "\n")
    person.sdb.address.for_print(local_or_permanent_address, separator)
  end
  
  # Returns the full address block for this student, for use in letters and envelopes
  def address_block(separator = "\n")
    "#{person.formal_firstname} #{person.lastname}" + separator + address_for_print(separator).to_s
  end
  
  # Returns true if there is a date in the +award_letter_sent_at+ field.
  def award_letter_sent?
    !award_letter_sent_at.blank?
  end
  
  # Returns true if any mentor letter has been sent yet.
  def mentor_letters_sent?
    mentors.collect{|m| !m.mentor_letter_sent_at.blank? }.include?(true)
  end

  # Generates the text of the award letter to be sent to the student. If a customized award letter text has been written to the
  # database, then we return that. Otherwise, we generate the text by parsing the template defined with 
  # Offering#applicant_award_letter_template_id.
  def award_letter_text
    return read_attribute(:award_letter_text) unless read_attribute(:award_letter_text).blank?
    template = offering.applicant_award_letter_template
    template.parse(self) if template
  end
  
  # Returns true if there is custom text stored in the +award_letter_text+ attribute.
  def custom_award_letter_text?
    !read_attribute(:award_letter_text).blank?
  end
  
  # Marks the award letters as being sent. This also parses and stores the templated letter so that the actual version is always stored 
  # in the database for the long-term.
  def send_award_letter
    update_attribute(:award_letter_sent_at, Time.now)
    update_attribute(:award_letter_text, award_letter_text)
  end
  
  # Finds or creates an associated ApplicationText object using the supplied +title+ parameter.
  def text(title)
    title = title.to_s if title.is_a?(Symbol)
    texts.find_or_create_by_title(title)
  end
  
  # If any of the +other_awards+ associated with this application include an award number restriction, this method will return
  # the total number of allowed awards for this applicant. If there are no restrictions, returns nil.
  def restricted_number_of_awards
    n = nil
    other_awards.each do |other_award|
      restricted_number = other_award.restrict_number_of_awards_to
      unless restricted_number.blank?
        n = restricted_number if n.nil? || restricted_number < n
      end
    end
    n
  end

  # Returns the application category or a blank string if one is not set. If there is an associated application_category, then we
  # use the title from that record. Otherwise, we check the +other_category_title+ and return it.
  def application_category_title
    return "" if application_category.nil?
    return application_category.title unless application_category.other_option?
    return "#{application_category.title}: #{other_category_title}" unless other_category_title.blank?
    return application_category.title unless application_category.nil?
    ""
  end

  # Returns the project_title stripped of all HTML tags. This is useeful for sending emails.
  def stripped_project_title
    Sanitize.clean(project_title) if project_title
  end
  
  # Creates a new ApplicationCompositeReport to use to generate a new PDF report about this application.
  def composite_report(application_reviewer = nil, offering_interview_interviewer = nil)
    ApplicationCompositeReport.new(self, application_reviewer, offering_interview_interviewer)
  end

  # When we assign this application to a moderated session, we have to clear out the moderator decision and moderator comments
  # so that the new moderator can put in new information.
  def offering_session_id=(session)
    self.write_attribute(:offering_session_id, session)
    self.write_attribute(:offering_session_order, nil)
    self.write_attribute(:moderator_comments, nil)
    self.write_attribute(:application_moderator_decision_type_id, nil)
  end

  # True if +awarded?+ is true but +dean_approved?+ is false.
  def awaiting_dean_approval?
    awarded? && !dean_approved?
  end

  # True if +dean_approved?+ is true but +financial_aid_approved?+ is false.
  def awaiting_financial_aid_approval?
    dean_approved? && !financial_aid_approved?
  end
  
  # True if +financial_aid_approved?+ is true but +disbursed?+ is false.
  def awaiting_disbursement?
    financial_aid_approved? && !disbursed?
  end

  # Returns the events that this application is eligible for, based on the +restrictions+ attribute of the event.
  # def eligible_events
  #   
  # end

  def app
    self
  end

  # Returns the first mentor marked as "primary" or, if no mentors are marked as primary, returns the first mentor.
  def primary_mentor
    primaries = mentors.select{ |m| m.primary? }
    primaries.empty? ? mentors.first : primaries.first
  end

  # Returns the primary mentor's department. Often used for sorting applications into groups. You can override this by
  # setting a new value in the +mentor_department+ attribute of the record. This might be useful if the primary mentor
  # is mentoring a student outside of his/her discipline and you don't want to group them in a weird way.
  def mentor_department
    return read_attribute(:mentor_department) unless read_attribute(:mentor_department).blank?
    primary_mentor.department if primary_mentor
  end
  
  def academic_department(delimiter = ", ")
    primary_mentor.academic_department.join(delimiter) if primary_mentor rescue primary_mentor.academic_department
  end

  # Assigns a new easel_number to this application. If the easel_number is different than what is currently stored in the DB,
  # then we take action to move other applications as needed or to fill in the gap we create by moving this application.
  # 
  # * If this application was previously assigned a different number, then we bump every higher record down a number.
  # So if we used to be assigned to #8, then #9 is moved down to #8, #10 is moved down to #9, and so forth.
  # 
  # * If another application is already assigned to the easel number we've been given, then we bump the existing record and all
  # higher records to the next higher easel number. So if we try to assign to number 8, the old #8 becomes #9, #9 becomes #10,
  # and so on.
  # 
  # === Notes
  # 
  # * These re-sorts are done only within the current location_section.
  # * If another application has its +lock_easel_number+ attribute set to +true+, then this method will _never_ change it.
  # def assign_easel_number(n)
  #   old_number = self.easel_number
  #   if old_number.to_i == n.to_i || n.nil? || old_number.nil?
  #     self.write_attribute(:easel_number, n)
  #   else
  #     transaction do
  #       unless location_section.presenters.find_by_easel_number(n).nil? # bump the numbers to make room for this new one
  #         next_app_to_reassign = location_section.presenters.find :all, 
  #                                   :conditions => ['easel_number >= ? 
  #                                                     AND easel_number <= ? 
  #                                                     AND (lock_easel_number IS NULL OR lock_easel_number = 0)', n, old_number], 
  #                                   :order => 'easel_number'
  #         unless next_app_to_reassign.size < 2
  #           puts "bumpup: reassigning #{next_app_to_reassign[0].easel_number} to #{next_app_to_reassign[1].easel_number}" 
  #           next_app_to_reassign[0].update_attribute(:easel_number, next_app_to_reassign[1].easel_number)
  #         end
  #       end
  #       self.write_attribute(:easel_number, n)
  #       puts "assign: assigning #{self.id.to_s} to #{n}"
  #       # unless old_number.blank? # fill in the gap that's left
  #       #   next_app_to_reassign = location_section.presenters.find :all, 
  #       #                             :conditions => ['easel_number > ? AND (lock_easel_number IS NULL OR lock_easel_number = 0)', old_number], 
  #       #                             :order => 'easel_number'
  #       #   if next_app_to_reassign.size < 2
  #       #     puts "fillin: reassigning #{next_app_to_reassign[0].easel_number} to #{old_number}"
  #       #     next_app_to_reassign[0].update_attribute(:easel_number, old_number)  
  #       #   end
  #       # end
  #       raise ActiveRecord::Rollback unless self.valid?
  #     end
  #   end
  # end
  
  # Returns the login_link for the primary applicant
  def login_link
    apply_url(:host => CONSTANTS[:base_url_host], :offering => offering)
  end

  # Returns the link that admin users can use to get directly to this application
  def admin_link
    admin_app_url(:host => CONSTANTS[:base_url_host], :offering => offering, :id => self)
  end

  def update_offering_session_counts
    if offering_session_id_changed?
      old_session = offering_session_id_change.first
      new_session = offering_session_id_change.last
      OfferingSession.update_counters old_session, :presenters_count => -1 unless old_session.nil?
      OfferingSession.update_counters new_session, :presenters_count => 1 unless new_session.nil?
    end
  end

  # Goes through this Offering's phase tasks (with "applicant" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
    self.task_completion_status_cache ||= {}
    tasks ||= offering.tasks.find(:all, :conditions => "context = 'applicant' AND completion_criteria != ''")
    tasks = [tasks] unless tasks.is_a?(Array)
    for task in tasks
      tcs = task_completion_statuses.find_or_create_by_task_id(task.id)
      tcs.result = self.instance_eval(task.completion_criteria.to_s)
      tcs.complete = tcs.result == true
      tcs.save
      self.task_completion_status_cache[task.id] = tcs.attributes
    end
    task_completion_status_cache
  end

  # Returns the task completion status hash for the specified task out of the +task_completion_status_cache+ hash. If the cache hasn't
  # been generated yet, this forces a reload (you can also manually force a reload by pass +true+ for +force_reload+).
  def task_completion_status(task_id, force_update = false)
    save if task_completion_status_cache.nil? || force_update
    task_completion_status_cache[task_id]
  end

  # Marks a certain task complete. Note that this should only be done for tasks that don't have a +completion_criteria+ set,
  # otherwise your action here will get overridden when #update_task_completion_status_cache! is run.
  def complete_task(task)
    self.task_completion_status_cache ||= {}
    task = OfferingAdminPhaseTask.find(task) unless task.is_a?(OfferingAdminPhaseTask)
    tcs = task_completion_statuses.find_or_create_by_task_id(task.id)
    tcs.result = true
    tcs.complete = true
    tcs.save
    self.task_completion_status_cache[task.id] = tcs.attributes
    tcs
  end

  private
  
  # If an invalid application_category is still assigned, then reset it to nil. A category is invalid if it does not match the
  # ApplicationType that is currently assigned to this application.
  def check_validity_of_application_category
    unless application_category.nil? || application_type.nil?
      application_category.reload && application_type.reload
      self.application_category_id = nil unless application_category.offering_application_type_id == application_type_id
    end
  end

  # Defines setter methods for all questions in this Offering that are defined as dynamic answers.
  # For checkbox, set answer with +offering_quesiton_option_id+ 
  def define_dynamic_answer_setters!
    if offering
      offering.questions.find_all_by_dynamic_answer(true).each do |oq|
        if oq.display_as.include?("checkbox_options")
           oq.options.each do |option|
             self.class.send :define_method, "dynamic_answer_#{oq.id.to_s}_#{option.id.to_s}=", Proc.new {|argv| set_answer(oq.id, argv, option.id)}
           end        
        else
          self.class.send :define_method, "dynamic_answer_#{oq.id.to_s}=", Proc.new {|argv| set_answer(oq.id, argv)}
        end        
      end
    end
  end
  
end
