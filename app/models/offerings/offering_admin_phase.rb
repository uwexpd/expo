# Helps coordinate the backend work of managing an Offering. An OfferingAdminPhase basically allows us to display segmented management functions on the Admin::Apply controller.
class OfferingAdminPhase < ActiveRecord::Base
  stampable
  belongs_to :offering
  has_many :tasks, :class_name => "OfferingAdminPhaseTask" do
    def show_for_success; find(:all, :conditions => { :show_for_success => true }); end
    def show_for_in_progress; find(:all, :conditions => { :show_for_in_progress => true }); end
    def show_for_failure; find(:all, :conditions => { :show_for_failure => true }); end
  end
  
  validates_uniqueness_of :sequence, :scope => :offering_id

  # Sorts based on sequence
  def <=>(other)
    sequence <=> other.sequence rescue -1
  end

  # Returns an array of the ApplicationStatusType names that are associated with this phase. Pass a result type
  # of :in_progress, :success, or :failure to limit it to that result type.
  # For example, ["new", "in_progress", "submitted", "complete"].
  def status_types(result_type = [:in_progress, :success, :failure])
    result_type = [result_type] unless result_type.is_a?(Array)
    results = []
    for t in result_type
      raise "Invalid status type. Must be one of :in_progress, :success, or :failure." unless [:in_progress, :success, :failure].include?(t)
      raw = read_attribute("#{t}_application_status_types")
      next if raw.blank?
      arr = []
      results << ApplicationStatusType.find_all_by_name(raw.split(/[\n\|\s]/)).collect(&:name)
    end
    results.flatten
  end
  
  # Return the next phase in the sequence.
  def next
    offering.admin_phases.find(:first, :conditions => ['sequence > ?', self.sequence], :order => 'sequence')
  end
  
  # Finds a task associated with this OfferingAdminPhase using the string that is passed. If +create_if_nil+ is set to +true+, then
  # this method will create a new task using the first parameter as the task title.
  def task(str, create_if_nil = false)
    t = tasks.find(:all).reject{|t| t.title.gsub(/\s/,"_").underscore != str.to_s.gsub(/\s/,"_").underscore}.first
    t = tasks.create(:title => str.to_s.humanize) if t.nil?
    t
  end
  
  # Returns true if the request task has been completed. If +create_if_nil+ is set to +true+, then
  # this method will create a new task using the first parameter as the task title.
  def task_complete?(str, create_if_nil = false)
    task(str, create_if_nil).nil? ? false : task(str, create_if_nil).complete?
  end

  # If the result_type is :success or :failure, then find applications that are past this status.
  # Otherwise, find applications that are currently in this status.
  def applications_for(result_type = :in_progress)
    @apps ||= {}
    return @apps[result_type] if @apps[result_type]
    @apps[result_type] = []
    result_type_array = [result_type] unless result_type.is_a?(Array)
    for t in result_type_array || result_type
      for status_type in status_types(t)
        if t.to_s == "success" || t.to_s == "failure"
          @apps[result_type] << offering.applications_past_status(status_type)
        else
          @apps[result_type] << offering.application_for_offerings.in_status(status_type)
        end
      end
    end
    @apps[result_type] = @apps[result_type].flatten.uniq.compact
  end
  
  def applications_for?(result_type = :in_progress)
    !applications_for(result_type).empty?
  end
  
  def all_applications
    @all_applications ||= applications_for([:in_progress, :success, :failure])
  end

  # Reviewer tasks are tasks that have context of "reviewer"
  def reviewer_tasks
    tasks.find(:all, :conditions => { :context => 'reviewers', :show_for_context_object_tasks => true })
  end

  # Interviewer tasks are tasks that have context of "interviewers" and +show_for_context_object_tasks+ is true.
  def interviewer_tasks
    tasks.find(:all, :conditions => { :context => 'interviewers', :show_for_context_object_tasks => true })
  end

  
  # Only returns applications whose current status is active in this phase
  # def active_applications
  #   @active_applications = []
  #   applications.each do |app|
  #     status_types.each do |status_type|
  #       @active_applications << app if app.current_status == status_type.application_status_type
  #     end
  #   end
  #   @active_applications
  # end
  
end
