# Defines a question that is asked of applicants during an application process. Questions are organized into OfferingPage objects, which allow you to group questions together on separate pages to display to applicants. An OfferingQuestion defines every aspect of how the question should be displayed and validated. This is accomplished through a combination of boolean and other attributes on the object itself, as well as associated OfferingQuestionOption and OfferingQuestionValidation associations.
# 
# Answers to questions are usually stored in "first-class" attributes on the ApplicationForOffering object or associated models; i.e., the answer controls an actual column in the database table as defined by the +attribute_to_update+ field. When there is no need for answers to be stored in first-class attributes, however, this question can define the +dynamic_answer+ boolean to true, which will result in answers being stored in the ApplicationAnswer associations instead. In this case, it may be harder to compare or analyze applications, so this should only be used for answers that are unique to this application process or do not need to be acted upon otherwise.
class OfferingQuestion < ActiveRecord::Base
  stampable
  belongs_to :offering_page
  has_many :offering_question_options, :dependent => :destroy
  has_many :options, :class_name => "OfferingQuestionOption", :dependent => :destroy
  has_many :application_answers, :dependent => :destroy
  has_many :validations, :class_name => "OfferingQuestionValidation", :dependent => :destroy

  delegate :offering, :to => :offering_page
  
  validates_presence_of :offering_page_id, :question
  
  validate :attribute_to_update_is_valid?

  QUESTION_TYPES_NOT_REQUIRING_ATTRIBUTE_TO_UPDATE = %w(awards mentors other_awards group_members files)

  # Users must define an +attribute_to_update+ or they must mark this question as a dynamic answer. Otherwise the question
  # is not valid.
  def attribute_to_update_is_valid?
    if attribute_to_update.blank? && !dynamic_answer? && !QUESTION_TYPES_NOT_REQUIRING_ATTRIBUTE_TO_UPDATE.include?(display_as)
      errors.add_to_base "You must specify the attribute to update, or mark this question as a 'dynamic answer'"
    end
  end

  def <=>(o)
    ordering <=> o.ordering rescue 0
  end
  
  def required?
    required || required_now || false
  end
  
  def character_limit?
    !character_limit.nil? && character_limit > 0
  end
  
  def word_limit?
    !word_limit.nil? && word_limit > 0
  end

  def short_question_title
    short_title.blank? ? question : short_title
  end
  
  def full_attribute_name
    model_to_update.blank? ? "#{attribute_to_update}" : "#{model_to_update}.#{attribute_to_update}"
  end
  
  def caption?
    !caption.blank?
  end

  def error_message
    error_text.blank? ? "#{short_question_title} is required" : error_text
  end
  
  # Returns +attribute_to_update+ from the object unless +dynamic_answer+ is true, in which case, returns an attribute
  # name that can be used with ApplicationForOffering's +method_missing+ to update an ApplicationAnswer instead.
  def attribute_to_update
    dynamic_answer? ? "dynamic_answer_#{self.id}" : read_attribute(:attribute_to_update)
  end
    
  def add_errors(page)
    add_required_error(page) if required?
    add_character_limit_error(page) unless character_limit.blank?
    add_word_limit_error(page) unless word_limit.blank?
    add_phone_number_error(page) if require_valid_phone_number?
    add_no_line_break_error(page) if require_no_line_breaks?
    add_special_errors(page)
    add_files_errors(page) if required?
    add_validation_errors(page) if !self.validations.empty?
  end
  
  # Returns an Array of possible options that can be used for #display_as by collecting all partial files in the 
  # /views/apply/questions directory. Each item in the array is a hash consisting of a :name and :title for each option --
  # :name should be the value stored in the record and :title can be used for display purposes.
  def self.display_as_options
    Dir.glob("app/views/apply/questions/*").sort.collect do |f|
      filename = f[/(\/)([A-Z,a-z,0-9,_]*)(.html.erb)/,2]
      { :name =>  filename,
        :title => filename.titleize
      }
    end
  end
  
  
  protected

  def add_error_message(page, message = nil)
    if message.nil?
      page.errors.add_to_base error_message
      message = " is required"
    else
      page.errors.add_to_base "#{short_question_title} #{message}"
    end
    page.errors.add "q#{self.id}", message
  end
  
  def add_required_error(page)
    begin
      if display_as == 'radio_options' && model_to_update.blank?
        add_error_message page and return if page.application_for_offering.instance_eval(attribute_to_update).nil?
      elsif display_as == 'checkbox_options'
        add_error_message page and return if page.application_for_offering.answers.find_all_by_offering_question_id(self.id).select{|a| a.answer != "false"}.empty?
      elsif display_as == 'application_text'
        add_error_message page and return if page.application_for_offering.text(attribute_to_update).blank?
      elsif display_as == 'application_category'
        add_error_message page and return if required? && !page.application_for_offering.application_category 
        add_error_message page and return if required? && page.application_for_offering.application_category.other_option? && page.application_for_offering.other_category_title.blank?
      elsif attribute_to_update == 'fullname'
        add_error_message page and return if required? && page.application_for_offering.person.firstname.blank?
        add_error_message page and return if required? && page.application_for_offering.person.lastname.blank?
      else
        if !model_to_update.blank?
          if required? && eval("page.application_for_offering.#{model_to_update}.#{attribute_to_update}.blank?")
            add_error_message page
          end
        elsif (required? && !attribute_to_update.blank? && page.application_for_offering.instance_eval(attribute_to_update).blank?)
          add_error_message page
        end
      end
    rescue
      add_error_message page, " -- could not check required error (add_required_error)"
    end
  end

  def add_character_limit_error(page)
    begin      
      unless character_limit.nil? || character_limit < 1         
        if display_as == 'application_text'
          character_count = page.application_for_offering.text(attribute_to_update).body.size rescue 0          
        else
          character_count = page.application_for_offering.instance_eval(attribute_to_update).size unless page.application_for_offering.instance_eval(attribute_to_update).nil?
        end        
        if character_count > character_limit
          add_error_message page, " is #{character_count - character_limit} characters too long (maximum #{character_limit} characters)."
        end
      end
    rescue
      add_error_message page, " -- could not check character limit error (add_character_limit_error)"
    end
  end
  
  
  def add_word_limit_error(page)
    begin
      if display_as == 'application_text'
        unless word_limit.nil? || word_limit < 1
          word_count = page.application_for_offering.text(attribute_to_update).body.split(/\S+/).size rescue 0
          if word_count > word_limit + 5
            add_error_message page, " is #{word_count - word_limit} words too long (maximum #{word_limit} words)."
          end
        end
      else
        unless word_limit.nil? || word_limit < 1 || page.application_for_offering.instance_eval(attribute_to_update).nil?
          word_count = page.application_for_offering.instance_eval(attribute_to_update).split(/\S+/).size
          if word_count > word_limit + 5
            add_error_message page, " is #{word_count - word_limit} words too long (maximum #{word_limit} words)."
          end
        end
      end
    rescue
      add_error_message page, " -- could not check word limit error (add_word_limit_error)"
    end
  end
  
  def add_phone_number_error(page)
    text = eval("page.application_for_offering.#{model_to_update}.read_attribute(attribute_to_update)")
    if !text.nil? && text.size < 10
      add_error_message page, " must have at least ten digits."
    end
  end
  
  def add_no_line_break_error(page)
    if display_as == 'application_text'
      text = page.application_for_offering.text(attribute_to_update).body
    else
      text = page.application_for_offering.instance_eval(attribute_to_update)
    end
    if text && text.include?("\n")
      add_error_message page, " must be one continuous paragraph; it cannot have any line breaks."
    end
  end
  
  
  
  def add_special_errors(page)
    if display_as == 'awards'
      add_awards_errors(page)
    elsif display_as == 'mentors'
      add_mentors_errors(page)    
    end
  end
  
  def add_awards_errors(page)
    duplicates = false; blanks = false; out_of_order = false; skipped_more_than_one = false
    user_application = page.application_for_offering
    # check for duplicates
    user_application.awards.each do |award|
      user_application.awards.each do |other_award|
        if award.requested_quarter_id == other_award.requested_quarter_id && (award.id != other_award.id)
          duplicates = true
        end
      end
    end
    # check for blanks
    i = 0; last_qtr = false
    user_application.awards.each do |award|
      i = i+1
	  # FIXME < below should probably be count the number of times award.requested_quarter_id is not blank and compair it to offering_page.offering.min_number_of_awards
      if award.requested_quarter_id.blank? && i < offering_page.offering.min_number_of_awards
        blanks = true
      end
      # check if any quarters are out of order
      if last_qtr && award.requested_quarter && award.requested_quarter < last_qtr
        out_of_order = true
      end
      last_qtr = award.requested_quarter
    end
    # check for skipped_more_than_one
    unless out_of_order
      last_qtr = false
      user_application.awards.each do |award|
        if last_qtr && award.requested_quarter && last_qtr.next != award.requested_quarter
          if last_qtr.next.next != award.requested_quarter # they're skipping two in a row here!
            skipped_more_than_one = true
          end
        end
        last_qtr = award.requested_quarter
      end
    end
    add_error_message page, " are invalid: the quarters you select for your awards must be different." if duplicates
    add_error_message page, " are invalid: you must choose at least #{offering_page.offering.min_number_of_awards} quarters." if blanks
    add_error_message page, " are invalid: the quarters you select must be in order." if out_of_order
    add_error_message page, " are invalid: you may skip one quarter of funding, but otherwise, the award quarters you select must be in sequence." if skipped_more_than_one
  end
  
  def add_mentors_errors(page)
    required_fields = %w(firstname lastname)
    user_application = page.application_for_offering
    user_application.mentors.each do |mentor|
      required_fields.each do |field|
        if mentor.read_attribute(field).blank?
          mentor.errors.add field, "can't be blank"
          page.errors.add_to_base "You left some of your mentor's name blank."
        end
      end
      if mentor.waive_access_review_right.nil? && offering.ask_applicant_to_waive_mentor_access_right?
        page.errors.add_to_base "You must choose whether or not to waive your record access rights for this application."
      end
      if !mentor.no_email && (mentor.email.blank? || !MustBeValidEmailAddressValidation::valid_email_address(mentor.email))
        page.errors.add_to_base "You must enter a valid e-mail address for your mentor."
      end
#      if !mentor.no_email && (mentor.email_confirmation.blank? || mentor.email != mentor.email_confirmation )
      if !mentor.no_email && !mentor.person && mentor.email != mentor.email_confirmation
        page.errors.add_to_base "The two e-mail addresses you type must match."
      end
    end
    if offering.has_minimum_mentor_qualification? && !user_application.mentors_meet_minimum_qualification?
      required_mentor_types = offering.mentor_types.select{|t| t.meets_minimum_qualification?}.collect(&:title)
      page.errors.add_to_base "At least one of your mentors must be of the following types: #{required_mentor_types.join(', ')}"
    end
  end

  def add_files_errors(page)
    user_application = page.application_for_offering
    file = user_application.files.find_by_offering_question_id(self)
    add_error_message(page) if file && file.file.nil?
    unless file.nil? || file.file.nil?
      add_error_message(page, "must be uploaded with PDF file. Your current file format is \"#{file.file.extension}\".") unless ["pdf","jpg","png","gif","xls","xlsx"].include?(file.file.extension)
    end
  end
  
  def add_validation_errors(page)
    self.validations.each do |validation|
      unless validation.allows? page.application_for_offering
        add_error_message page, validation.error_message
      end
    end      
  end

end
