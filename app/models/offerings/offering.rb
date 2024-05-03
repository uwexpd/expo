# An "Offering" in EXPo is anything that a student (or other user, potentially) can apply for.  Common examples would be scholarships, fellowships, programs (like a summer program), internships, courses that require an application process, etc. test
class Offering < ActiveRecord::Base
  stampable

  default_scope :joins => "LEFT JOIN `quarters` ON `quarters`.`id` = `offerings`.`quarter_offered_id`", 
                :order => "IF(`quarter_offered_id` IS NULL, `year_offered`, `quarters`.`year`) DESC,
                           IF(`quarter_offered_id` IS NULL, 0, `quarters`.`quarter_code_id`) DESC"

  has_many :application_for_offerings, 
          :dependent => :destroy, 
          :include => [ :person, 
                        {:current_application_status => :application_status_type }, 
                        {:group_members => :person },
                         :mentors
                      ] do
    # Return applications with current_status, same as in_status. (Not sure why it is duplicate)
    def with_status(status_name)
      find :all, 
            :joins => [:person, {:current_application_status => :status_type }], 
            :include => [ :person,
                          { :current_application_status => :application_status_type }, 
                          { :group_members => :person },
                          { :mentors => :person }
                        ],
            :conditions => ['name = ?', status_name.to_s]
    end
    def in_status(status_name)
      find :all, 
            :joins => [:person, {:current_application_status => :status_type }], 
            :include => [ :person,
                          { :current_application_status => :application_status_type }, 
                          { :group_members => :person },
                          { :mentors => :person }
                        ],
            :conditions => ['name = ?', status_name.to_s]
    end
    def awarded
      reject{|a| !a.awarded?}
    end
    def awaiting_dean_approval
      find_all{|a| a.awaiting_dean_approval? }
    end
    def awaiting_financial_aid_approval
      find_all{|a| a.awaiting_financial_aid_approval? }
    end
    def awaiting_disbursement
      find_all{|a| a.awaiting_disbursement? }
    end
  end
  has_many :valid_status_applications,
            :class_name => "ApplicationForOffering",
            :include => [ {:current_application_status => :application_status_type } ],
            :conditions => ['current_application_status_id is not null']

  has_many :application_group_members, :through => :application_for_offerings, :source => :group_members
  has_many :people, :through => :application_for_offerings
  has_many :pages, :class_name => "OfferingPage", :order => "ordering", :dependent => :destroy
  has_many :questions, :through => :pages
  belongs_to :unit
  has_many :restrictions, :class_name => "OfferingRestriction", :foreign_key => "offering_id", :dependent => :destroy
  has_many :exemptions, :through => :restrictions
  belongs_to :quarter_offered, :class_name => "Quarter", :foreign_key => "quarter_offered_id"
  belongs_to :accountability_quarter, :class_name => "Quarter", :foreign_key => "accountability_quarter_id"
  belongs_to :first_eligible_award_quarter, :class_name => "Quarter", :foreign_key => "first_eligible_award_quarter_id"
  has_many :statuses, :class_name => "OfferingStatus", :dependent => :destroy
  belongs_to :accepted_offering_status, :class_name => "OfferingStatus", :foreign_key => "accepted_offering_status_id"
  belongs_to :declined_offering_status, :class_name => "OfferingStatus", :foreign_key => "declined_offering_status_id"
  has_many :offering_reviewers, :class_name => "OfferingReviewer", :dependent => :nullify
  has_many :offering_interviewers, :class_name => "OfferingInterviewer", :dependent => :nullify
  has_many :interview_timeblocks, :class_name => "OfferingInterviewTimeblock", :dependent => :destroy
  has_many :interviews, :class_name => "OfferingInterview", :dependent => :destroy
  has_many :admin_phases, :class_name => "OfferingAdminPhase", :dependent => :destroy
  has_many :phases, :class_name => "OfferingAdminPhase"
  has_many :tasks, :through => :phases
  has_many :other_award_types, :class_name => "OfferingOtherAwardType", :dependent => :destroy
  has_many :invitation_codes, :class_name => "OfferingInvitationCode", :dependent => :destroy
  has_many :events, :dependent => :nullify
  has_many :application_review_decision_types, :dependent => :destroy do
    def yes_option
      find(:first, :conditions => { :yes_option => true })
    end
    def no_option
      find(:first, :conditions => { :title => 'No' })
    end
  end
  has_many :application_interview_decision_types, :dependent => :destroy do
    
    def yes_option
      find(:first, :conditions => { :yes_option => true })
    end
    def no_option
      find(:first, :conditions => { :title => 'No' })
    end
    def contingency_option
      find(:first, :conditions => { :contingency_option => true })
    end
  end
  has_many :application_final_decision_types, :dependent => :destroy do
    def yes_option
      find(:first, :conditions => { :yes_option => true })
    end
    def no_option
      find(:first, :conditions => { :title => 'No' })
    end
  end
  has_many :application_moderator_decision_types, :dependent => :destroy
  belongs_to :dean_approver, :class_name => "User", :foreign_key => "dean_approver_id"
  belongs_to :financial_aid_approver, :class_name => "User", :foreign_key => "financial_aid_approver_id"
  belongs_to :disbersement_approver, :class_name => "User", :foreign_key => "disbersement_approver_id"
#  belongs_to :current_offering_admin_phase, :class_name => "OfferingAdminPhase", :foreign_key => "current_offering_admin_phase_id"
  belongs_to :review_committee, :class_name => "Committee", :foreign_key => "review_committee_id"
  belongs_to :interview_committee, :class_name => "Committee", :foreign_key => "interview_committee_id"
  belongs_to :moderator_committee, :class_name => "Committee", :foreign_key => "moderator_committee_id"
  has_many :review_criterions, :class_name => "OfferingReviewCriterion"
  has_many :offering_committee_member_restrictions
  belongs_to :early_mentor_invite_email_template, :class_name => "EmailTemplate", :foreign_key => "early_mentor_invite_email_template_id"
  belongs_to :mentor_thank_you_email_template, :class_name => "EmailTemplate", :foreign_key => "mentor_thank_you_email_template_id"
  has_many :mentor_questions, :class_name => "OfferingMentorQuestion", :dependent => :destroy
  has_many :mentor_types, :class_name => "OfferingMentorType", :dependent => :destroy
  belongs_to :applicant_award_letter_template, :class_name => "TextTemplate", :foreign_key => "applicant_award_letter_template_id"
  belongs_to :mentor_award_letter_template, :class_name => "TextTemplate", :foreign_key => "mentor_award_letter_template_id"
  belongs_to :group_member_validation_email_template, :class_name => "EmailTemplate", :foreign_key => "group_member_validation_email_template_id"
  has_many :application_types, :class_name => "OfferingApplicationType", :dependent => :destroy
  has_many :application_categories, :class_name => "OfferingApplicationCategory", :dependent => :destroy
  has_many :location_sections, :class_name => "OfferingLocationSection", :dependent => :destroy
  has_many :dashboard_items, :class_name => "OfferingDashboardItem", :dependent => :destroy, :order => "sequence"
  has_many :sessions, :class_name => "OfferingSession", :order => "identifier ASC", :dependent => :destroy do
    def in_group(group); find(:all, :conditions => { :session_group => group }); end
    def for_type(type_id); find(:all, :conditions => { :offering_application_type_id => type_id }); end
    def for_type_in_group(type_id, group); find(:all, 
                          :conditions => { :session_group => group, :offering_application_type_id => type_id }); end
  end
  has_many :offering_award_types, :dependent => :destroy
  has_many :award_types, :through => :offering_award_types
  belongs_to :activity_type
  
  after_create :create_starting_statuses, :create_starting_restrictions
  
  validates_presence_of :name, :unit_id
  
  # A list of features that you can turn on or off for an Offering.
  FEATURES = [  ["Awards",			    :uses_awards],
      		 			["Group Members",	  :uses_group_members],
      		 			["Mentors",			    :uses_mentors],
      					["Interviews",		  :uses_interviews],
      					["Moderators", 		  :uses_moderators],
      					["Confirmation", 	  :uses_confirmation],
      					["Award Acceptance",:uses_award_acceptance],
      					["Lookup Tool",     :uses_lookup],
      					["Online Proceedings",:uses_proceedings]  ]
  
  PLACEHOLDER_CODES = %w(title quarter_offered.title quarter_offered.year quarter_offered.academic_year)
  PLACEHOLDER_ASSOCIATIONS = %w(quarter_offered unit)
  
  OFFERINGS_CACHE = FileStoreWithExpiration.new("tmp/cache/offerings")
  
  upload_column :proceedings_pdf_letterhead,
                :root_dir => File.join(RAILS_ROOT, 'files'),
                :store_dir => proc{|record, file| File.join('offering', 'proceedings_pdf_letterhead', "#{record.id}")}
  
  def <=>(o)
    quarter_offered <=> o.quarter_offered rescue 0
  end
  
  # Used for change logs and other objects that request a unified "name" from this object.
  def identifier_string
    title
  end
  
  # Formats this Offering's deadline using the format "Monday, July 07, 2008 at 05:00 PM"
  def deadline_pretty
    self.deadline.strftime "%A, %B %d, %Y at %I:%M %p"
  end
  
  def mentor_deadline_pretty
    self.mentor_deadline.strftime "%A, %B %d, %Y at %I:%M %p"
  end

  # Constructs a title that includes the quarter_offered, if set.
  def title
    title = "#{name}"
    title << " #{quarter_offered.title}" if quarter_offered
    title
  end

  # Returns true if the deadline for this Offering is in the past.
  def past_deadline?
    self.deadline < Time.now
  end

  # An Offering is open if we're past the +open_date+ and before the deadline
  def open?
    open_date < Time.now && !past_deadline? rescue nil
  end

  # An Offering is considered "current" if the +quarter_offered+ is the current quarter or if +year_offered+ is the current year.
  def current?
    (quarter_offered == Quarter.current_quarter) || (year_offered == Time.now.year)
  end

  # An Offering is considered "past" if the +quarter_offered+ is older than the current quarter or if +year_offered+ is older than  
  # the current year.
  def past?
    return quarter_offered < Quarter.current_quarter unless quarter_offered.nil?
    return year_offered < Time.now.year unless year_offered.nil?
    return false
  end

  # Returns the set of OfferingReviewers that are valid to be assigned to the specified ApplicationForOffering.
  # For example, this will not include reviewers that have already been assigned to this application or reviewers 
  # that serve as a mentor for this appliction.
  def reviewers_for(app)
    res = Array.new(self.reviewers)
    res = res.delete_if {|r| app.mentors.collect(&:person).include?(r.person)} unless allow_to_review_mentee
    res = res.delete_if {|r| app.reviewers.collect(&:person).include?(r.person)}
  end

  # Returns the reviewers for this Offering. If +review_committee+ is set, then we return the members of that committee that
  # are active for the quarter that this offering is offered. If +review_committee+ is nil, we return the associated OfferingReviewers
  # that are defined for this Offering. Typically, we use the committee, but this method allows us to still use the old
  # OfferingReviewer objects if we want to.
  def reviewers
    if review_committee.nil?
      offering_reviewers
    else
      review_committee.members.active_for(quarter_offered)
    end
  end

  # Just like +reviewers+, except for interviewers.
  def interviewers
    if interview_committee.nil?
      offering_interviewers
    else
      interview_committee.members.active_for(quarter_offered)
    end
  end
  
  def moderators
    moderator_committee.nil? ? [] : moderator_committee.members
  end
  
  # Identifies whether or not this Offering uses a scored review or not. If there are review_criterions defined for this Offering,
  # then assume that we are using a score-based review process (meaning that reviewers submit a set of scores that are used in the
  # selection process), otherwise assume that it is not (meaning that reviewers or the review committee makes a decision about each
  # application independently).
  def uses_scored_review?
    !review_criterions.empty?
  end

  # Identifies whether or not this Offering requires mentors to answer additional questions in addition to submitting a letter of support.
  def asks_mentor_questions?
    !mentor_questions.empty?
  end

  # Returns true if any of this Offering's mentor_types has the +meets_minimum_qualification+ bit set to true.
  def has_minimum_mentor_qualification?
    mentor_types.collect(&:meets_minimum_qualification?).include?(true)
  end

  # Returns the current OfferingAdminPhase for this Offering, or, if it is nil, returns the first admin_phase associated with this Offering.
  def current_offering_admin_phase
    current_offering_admin_phase_id.nil? ? admin_phases.first : OfferingAdminPhase.find(current_offering_admin_phase_id)
  end
  
  # Updates the current_offering_admin_phase_id to that of the phase that is passed.
  def current_offering_admin_phase=(new_phase)
    update_attribute(:current_offering_admin_phase_id, new_phase.id)
  end

  # Returns a message that can be displayed to a user about the confidentiality of the related information. Typically, this
  # is used when printing out sensitive data from EXPo. It includes the text "CONFIDENTIAL" and, if an Offering has the
  # +destroy_by+ attribute defined, it will include that as well.
  def confidentiality_note
    note = "CONFIDENTIAL"
    note += " &bull; Destroy by #{destroy_by} &bull; CONFIDENTIAL" unless destroy_by.blank?
  end

  # Returns the earliest time that an OfferingInterviewTimeblock starts
  def earliest_interview_timeblock_start
    interview_timeblocks.find(:first, :order => 'start_time').start_time
  end
  
  # Returns the latest time that an OfferingInterviewTimeblock ends
  def latest_interview_timeblock_end
    interview_timeblocks.find(:first, :order => 'end_time DESC').end_time
  end

  # Returns all applications that were invited for interview for this Offering
  def applications_for_interview
    apps = application_for_offerings.delete_if {|a| !a.invited_for_interview? }
  end

  def dean_approver_uw_netid
    dean_approver ? dean_approver.login : nil
  end
  
  def financial_aid_approver_uw_netid
    financial_aid_approver ? financial_aid_approver.login : nil
  end
    
  def disbersement_approver_uw_netid
    disbersement_approver ? disbersement_approver.login : nil
  end

  # Returns an array of Applications within this Offering that has gone through the specified status name. 
  # Note that this is NOT necessarily this application's _current_ status. 
  # Does not include applications that have been cancelled, unless you override that by setting +false+ as the
  # second parameter.
  # By default, this method does not take into consideration
  # the sequence of statuses for this offering (so, for instance, if an application gets to "approved" but then later
  # gets moved back to "submitted" then this application is no longer "past" the approved status.) You can override this
  # by setting +true+ for the third parameter.
  def applications_with_status(status_name, include_cancelled = false, respect_sequence = false)
    apps = []
    
    if respect_sequence
      offering_status = statuses.find(:first, 
                                      :joins => :application_status_type, 
                                      :conditions => { "application_status_types.name" => status_name.to_s })
      status_sequence_mapping = {}
      for os in statuses.find(:all)
        status_sequence_mapping[os.application_status_type_id] = os.sequence
      end
    end
    
    app_ids = ApplicationForOffering.find(:all,
      :select => "application_for_offerings.id",
      :joins => { :statuses => :application_status_type },
      :conditions => {  :offering_id => self.id, 
                        "application_status_types.name" => status_name.to_s 
                      }
    ).collect(&:id)
    
    raw_apps = ApplicationForOffering.find(app_ids.uniq, 
      :select => "application_for_offerings.*",
      :include => [{:current_application_status => :application_status_type }, :person],
      :joins => :person,
      :order => "lastname, firstname"
    )
    
    for app in raw_apps
      next if !include_cancelled && app.current_status_name == 'cancelled'
      if respect_sequence
        current_status_sequence = status_sequence_mapping[app.current_application_status.application_status_type_id]
        next if current_status_sequence && current_status_sequence < offering_status.try(:sequence)
      end
      apps << app
    end
    
    apps


    # apps = []
    # raw_apps = application_for_offerings.find(:all, 
    #                                           :include => [{:current_application_status => :application_status_type }, 
    #                                                        {:application_statuses => :status_type }])
    # raw_apps.each do |app|
    #   app.application_statuses.each do |status|
    #     if status.status_type.name == status_name.to_s
    #       apps << app unless !include_cancelled && app.current_status_name == 'cancelled'
    #     end
    #   end
    # end
    # apps.uniq
  end

  # Shortcut for applications_with_status(status_name, include_cancelled, TRUE)
  def applications_past_status(status_name, include_cancelled = false)
    applications_with_status(status_name, include_cancelled, true)
  end

  # Copies this Offering to a new Offering object, and creates associated objects as well.
  def deep_clone!
    opts = {}
    opts[:except] = [
      :current_offering_admin_phase_id, 
      :complete, 
      :financial_aid_approval_request_sent_at,
      :application_for_offerings_count,
      :enable_award_acceptance,
      :accepted_offering_status_id,
      :declined_offering_status_id
      ]
    opts[:include] = [
      {:pages => {:questions => [:options, :validations]}}, 
      {:statuses => :emails},
      {:admin_phases => {:tasks => :extra_fields}},
      :restrictions,
      :mentor_questions,
      :mentor_types,
      :review_criterions,
      :application_review_decision_types,
      :application_interview_decision_types,
      :application_final_decision_types,
      :application_moderator_decision_types,
      :dashboard_items,
      :application_types,
      :application_categories,
      :offering_committee_member_restrictions,
      :sessions,
      :offering_award_types,
      :other_award_types,
      :location_sections
      ]
    self.clone(opts)
  end
  
  # Calculates the maximum total score that an applicant can receive from a reviewer.
  def max_total_score
    review_criterions.collect{|c| c.max_score}.sum
  end
  
  # Returns all ApplicationForOfferings who have an ApplicationReviewDecisionType of yes.
  def applications_awarded_by_review_committee
    application_for_offerings.find(:all, 
      :conditions => { :application_review_decision_type_id => application_review_decision_types.yes_option.id })
  end

  # Returns all ApplicationForOfferings who have an ApplicationFinalDecisionType of yes.
  def applications_awarded_by_final_committee
    application_for_offerings.find(:all,
      :joins => :application_final_decision_type,
      :conditions => { "application_final_decision_types.yes_option" => true })
  end
  
  # Returns all of the Institutions that have been provided OfferingInvitationCodes.
  def invited_institutions
    invitation_codes.collect(&:institution).uniq.compact
  end

  # Parses the +guest_postcard_layout+ using the object passed to it. Makes available the following variables within
  # the parsed text: 
  # 
  # * +@object+ is the passed object
  # * +@offering+ is this Offering (+self+)
  # * +@app+ is the relevant ApplicationForOffering (which might be the same as @object, but not if @object is a group member)
  def parse_guest_postcard_layout(object)
    @object = object
    @offering = self
    @app = @object.is_a?(ApplicationForOffering) ? @object : @object.application_for_offering
    res = ERB.new(guest_postcard_layout.to_s, 0, "%<>").result(binding)
  end

  def confirmations_allowed?
    !disable_confirmation?
  end

  # Returns "Mentor" unless +alternate_mentor_title+ is set to something else.
  def mentor_title
    alternate_mentor_title.blank? ? "Mentor" : alternate_mentor_title
  end

  # Returns "Welcome" unless +alternate_welcome_page_title+ is set to something else, like "MySymposium".
  def welcome_page_title
    alternate_welcome_page_title.blank? ? "Welcome" : alternate_welcome_page_title
  end

  # Every offering starts with three default statuses: New, In Progress, and Submitted.
  def create_starting_statuses
    new_status_attributes = { :public_title => "New",
                              :application_status_type => ApplicationStatusType.find_or_create_by_name("new"),
                              :disallow_user_edits => 0,
                              :disallow_all_edits => 0,
                              :allow_application_edits => 1 }
    statuses.create(new_status_attributes)
    in_progress_status_attributes = { :public_title => "In Progress",
                              :application_status_type => ApplicationStatusType.find_or_create_by_name("in_progress"),
                              :disallow_user_edits => 0,
                              :disallow_all_edits => 0,
                              :allow_application_edits => 1 }
    statuses.create(in_progress_status_attributes)
    submitted_status_attributes = { :public_title => "Submitted",
                              :application_status_type => ApplicationStatusType.find_or_create_by_name("submitted"),
                              :disallow_user_edits => 1,
                              :disallow_all_edits => 0,
                              :allow_application_edits => 0 }
    statuses.create(submitted_status_attributes)
  end
  
  # Every offering starts with two default restrictions: BeforeOpenRestriction and PastDeadlineRestriction.
  def create_starting_restrictions
    restrictions << BeforeOpenRestriction.create(:offering => self)
    restrictions << PastDeadlineRestriction.create(:offering => self)
  end

  # Defaults #final_decision_weight_ratio to 50/50 if it has not been set.
  def final_decision_weight_ratio
    r = read_attribute(:final_decision_weight_ratio)
    (r.nil? || r.zero?) ? 0.5 : r
  end

  # Returns a printable representation of the weighting used in the final decision scored selection process.
  def final_decision_weight_ratio_pretty
    reviewer_weight = final_decision_weight_ratio * 100
    interviewer_weight = 100 - reviewer_weight
    "R=#{'%.0f' % reviewer_weight} / I=#{'%.0f' % interviewer_weight}"
  end

  # Based on the +count_method_for_accountability+, returns the objects to count in the accountability process.
  def accountability_objects
    case count_method_for_accountability.to_sym
    when :awardees      then awardees
    when :presenters    then presenters
    when :complete      then complete
    else []
    end
  end

  def awardees;      application_for_offerings.awarded; end
  def presenters;    (sessions.collect(&:presenters) + sessions.collect(&:group_members)).flatten; end
  def complete;      applications_with_status(:complete); end

  # Returns the OfferingApplicationType that is assigned to the "Poster Session" application type.
  def poster_application_type
    application_types.find(:first, :joins => :application_type, :conditions => { "application_types.title" => "Poster Presentation" })
  end

  # Returns the OfferingApplicationType that is assigned to the "Oral Session" application type.
  def oral_application_type
    application_types.find(:first, :joins => :application_type, :conditions => { "application_types.title" => "Oral Presentation" })
  end  

  # Returns the OfferingApplicationType that is assigned to the "Visual Arts" application type.
  def visual_arts_application_type
    application_types.find(:first, :joins => :application_type, :conditions => { "application_types.title" => "Visual Arts & Design" })
  end
  
  # Returns the OfferingApplicationType that is assigned to the "Performing Arts" application type.
  def performing_arts_application_type
    application_types.find(:first, :joins => :application_type, :conditions => { "application_types.title" => "Performing Arts" })
  end

  # Returns a new or existing Population with the requested starting set. The starting set can be any valid association
  # or method of this Offering that returns an array of objects. If the population doesn't exist, it is created and the
  # +system+ boolean flag is set.
  # 
  # Since Populations must have a unique title, this method will automatically increment the title for a newly-created
  # Population if needed. So if a population with the name already exists, this method will create a population with a
  # "2" at the end of the title. If something with a "2" already exists, the new title will have a "3", and so on, until
  # a valid title is found.
  def population(starting_set)
    starting_set = starting_set.to_s if starting_set.is_a?(Symbol)
    p = Population.find_or_initialize_by_populatable_type_and_populatable_id_and_starting_set_and_conditions_counter(
          "Offering", self.id, starting_set, 0)
    if p.new_record?
      p.title = "#{self.title}: #{starting_set.titleize}"
      until p.valid? && !p.errors.on(:title)
        if p.title[/\d+$/].nil?
          p.title += " 2"
        else
          new_num = p.title[/\d+$/].to_i + 1
          p.title.gsub!(/\d+$/, new_num.to_s)
        end
      end 
      p.system = true
      p.description = "Automatically generated by Offering ##{self.id} from starting set '#{starting_set}'"
      p.access_level = "everyone"
      p.save
    end
    p
  end

  # Creates (or restores from cache) a hash with keys of major names and values of arrays of application ID numbers.
  # Default cache is 24 hours.
  def majors_mapping(status = :confirmed, reference_quarter = nil)
    reference_quarter ||= Quarter.find_by_date(deadline)
    OFFERINGS_CACHE.fetch("majors_mapping_#{id}_#{status.to_s.underscore}_#{reference_quarter.abbrev}", :expires_in => 24.hours) do
      @apps = application_for_offerings.with_status(status)
      majors ||= {}
      all_apps ||= (@apps + @apps.collect(&:group_members)).flatten.compact
      applicants ||= all_apps.collect(&:person).flatten.compact.uniq
      major_extras ||= MajorExtra.all
      major_abbrs ||= {}
      for major_extra in major_extras
        major_abbrs[major_extra.major_abbr.strip] = [] unless major_abbrs[major_extra.major_abbr.strip]
        major_abbrs[major_extra.major_abbr.strip] << major_extra
      end
      for a in all_apps
        if a.person
          # print a.person.id.to_s.ljust(10)
          if a.person.is_a?(Student) && (Quarter.current_quarter != Quarter.find_by_date(confirmation_deadline))
            sk = a.person.system_key
            rq = reference_quarter            
            t = StudentTranscript.find(sk, rq.year, rq.quarter_code_id) rescue nil
            t = (StudentTranscript.find(sk, rq.prev.year, rq.prev.quarter_code_id) rescue nil) if t.nil?
            ref_majors = t.nil? ? [] : t.majors
            # puts ref_majors.size
          else
            ref_majors = a.person.majors
          end
          major_extra = nil
          for major in ref_majors
            major_name = major
            if major.is_a?(StudentMajor) || major.is_a?(StudentTranscriptMajor)
              # major_extra_field = @major_extras.select{|m| major.major_abbr.strip == m.major_abbr.strip }
              # major_extra = major_extra_field.select{|m| major.branch == m.major_branch && major.pathway == m.major_pathway }
              if major_abbrs[major.major_abbr.strip]
                major_extra = major_abbrs[major.major_abbr.strip].find{|m| major.branch == m.major_branch && major.pathway == m.major_pathway }
              end
              major_name = major_extra.nil? ? major.full_name : major_extra.fixed_name
            end
            majors[major_name] = (majors[major_name].nil? ? [a.app.id] : majors[major_name] << a.app.id) unless major_name.blank?
          end
        end
      end
      majors
    end
  end
  
  # Creates (or restores from cache) a hash with keys of department names and values of arrays of application ID numbers.
  # Default cache is 24 hours.
  def departments_mapping(status = :confirmed, academic_department = false)
    OFFERINGS_CACHE.fetch("departments_mapping_#{id}_#{status.to_s.underscore}", :expires_in => 24.hours) do
      @apps = application_for_offerings.with_status(status)
      departments = {}
      for iapp in @apps
        dept = academic_department==true ? iapp.primary_mentor.academic_department : iapp.mentor_department        
        dept.each{|d| departments[d] = (departments[d].nil? ? [iapp.id] : departments[d] << iapp.id) } unless dept.blank?        
      end
      departments
    end
  end
  
  # Creates (or restores from cache) a hash with keys of award names and values of arrays of application ID numbers.
  # Default cache is 24 hours.
  def awards_mapping(status = :confirmed)
    OFFERINGS_CACHE.fetch("awards_mapping_#{id}_#{status.to_s.underscore}", :expires_in => 24.hours) do
      @apps = application_for_offerings.with_status(status)
      awards = {}
      for iapp in @apps
        award = iapp.other_awards.collect(&:scholar_title).flatten.compact
        for index in (0...award.length)
          awards[award[index]] = (awards[award[index]].nil? ? [iapp.id] : awards[award[index]] << iapp.id) unless award.blank?  
        end
      end      
      awards
    end
  end

  # Creates (or restores from cache) a hash with keys of campus names and values of arrays of application ID numbers.
  # Default cache is 24 hours.
  def campus_mapping(status = :confirmed, reference_quarter = nil)
    reference_quarter ||= Quarter.find_by_date(deadline)
    OFFERINGS_CACHE.fetch("campus_mapping_#{id}_#{status.to_s.underscore}_#{reference_quarter.abbrev}", :expires_in => 24.hours) do
      @apps = application_for_offerings.with_status(status)
      campus ||= {}
      all_apps ||= (@apps + @apps.collect(&:group_members)).flatten.compact

      all_apps.each do |a|
        if a.person
          # print "DEBUG person => #{a.person.id.to_s.ljust(10)}"
          if a.person.is_a?(Student)
            sk = a.person.system_key
            rq = a.offering.quarter_offered || Quarter.find_by_date(a.offering.deadline)
            t = StudentTranscript.find([sk, rq.year, rq.quarter_code_id]) rescue nil
            t = (StudentTranscript.find([sk, rq.prev.year, rq.prev.quarter_code_id]) rescue nil) if t.nil?
            ref_majors = t.nil? ? [] : t.majors
          else
            ref_majors = a.person.majors
          end
          #puts "DEBUG ref_majors => #{ref_majors.inspect}"
          ref_majors.each do |major|
            #puts "DEBUG major => #{major}"
            if major.is_a?(StudentMajor) || major.is_a?(StudentTranscriptMajor)
              campus_name = major.is_a?(StudentTranscriptMajor) ? major.branch_name : major.major_branch_name
            else
              campus_name = "Other Campus"
            end
            campus[campus_name] = (campus[campus_name].nil? ? [a.app.id] : campus[campus_name] << a.app.id) unless campus_name.blank?
          end
        end
      end
      campus
    end
  end


  def session_location_mapping(status = :confirmed)
    OFFERINGS_CACHE.fetch("session_location_mapping_#{id}_#{status.to_s.underscore}", :expires_in => 24.hours) do
      @apps = application_for_offerings.with_status(status)      
      locations = {}
      for iapp in @apps
        if iapp.application_type && iapp.application_type.title == "Poster Presentation"
          location = iapp.location_section.title if iapp.location_section
        else
          location = iapp.offering_session.location if iapp.offering_session
        end        

        ['MGH','HUB','CSE'].each do |building|
          if location && location.include?(building)
            locations[building] = (locations[building].nil? ? [iapp.id] : locations[building] << iapp.id)
          end          
        end
      end
      locations
    end
  end

end