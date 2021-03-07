class Quarter < ActiveRecord::Base
  include Comparable
  stampable
  belongs_to :quarter_code
  validates_presence_of :quarter_code, :year, :first_day
  
  has_many :organization_quarters, 
              :include => [:organization, 
                          { :statuses => :organization_quarter_status_type }, 
                          :staff_contact_user, 
                          :positions] do
    def for_unit(unit)
      find(:all, :conditions => { :unit_id => (unit.class == Fixnum ? unit : unit.id)})
    end
  end
  has_many :organizations, :through => :organization_quarters
  has_many :organization_contacts, :finder_sql => 'SELECT *, `organization_contacts`.`id` AS `id` FROM `organization_contacts`
              INNER JOIN `organizations` ON (`organization_contacts`.`organization_id`=`organizations`.`id`)
              INNER JOIN `organization_quarters` ON (`organizations`.`id`=`organization_quarters`.`organization_id`)
              INNER JOIN `people` ON (`organization_contacts`.`person_id`=`people`.`id`)
              WHERE ((`organization_quarters`.`quarter_id` = #{id}))'
  has_many :service_learning_positions, :through => :organization_quarters, :source => :positions do
    # find by unit, can pass unit id or unit object
    def for_unit(unit)
      find(:all, :conditions => {:organization_quarters => {:unit_id => (unit.nil? ? nil : unit.class == Fixnum ? unit : unit.id)}})
    end
  end
  has_many :service_learning_placements, :class_name => 'ServiceLearningPlacement', 
           :finder_sql  => 'SELECT *, `service_learning_placements`.`id` AS `id` FROM `service_learning_placements`  
                            INNER JOIN `service_learning_positions` ON
                              (`service_learning_placements`.`service_learning_position_id`=`service_learning_positions`.`id`)   
                            INNER JOIN `organization_quarters` ON
                            	(`service_learning_positions`.`organization_quarter_id`=`organization_quarters`.`id`)
                            WHERE ((`organization_quarters`.`quarter_id` = #{id}))'
  has_many :service_learning_courses, :include => :courses do
    def for_unit(unit)
      find(:all, :conditions => {:unit_id => (unit.nil? ? nil : unit.class == Fixnum ? unit : unit.id)})
    end
  end
  has_many :service_learning_evaluation_questions, :class_name => "EvaluationQuestion", :as => :evaluation_questionable do
    def for_unit(unit) 
      find(:all, :conditions => {:unit_id => (unit.nil? ? nil : unit.class == Fixnum ? unit : unit.id)})
    end
  end
  has_many :service_learning_self_placements

  default_scope :order => "year, quarter_code_id"

  PLACEHOLDER_CODES = %w(title abbrev first_day quarter_code_id year academic_year)
    
  # Overrides ActiveRecord#to_param so that we can use the abbreviation instead of the ID of this object, e.g. "SPR2008" instead of "13".
  def to_param
    abbrev
  end
  
  # Returns the record for this quarter out of the SDB's calendar table. Returns a StudentCalendarQuarter object.
  def sdb
    StudentCalendarQuarter.find("0#{year.to_s}#{quarter_code_id.to_s}")
  end
  
  # Returns the quarter abbreviation in the form of "QQQYYYY" (e.g., "AUT2009").
  def abbrev
    "#{quarter_code.abbreviation}#{year}"
  end

  # Searches for Quarters using the quarter abbreviation in the form of "QQQYYYY". Pass an array of abbreviations to find multiple.
  def self.find_by_abbrev(a)
    return nil if a.blank?
    return a.collect{|i| Quarter.find_by_abbrev(i)} if a.is_a?(Array)
    qc = QuarterCode.find_by_abbreviation a[0,3]
    Quarter.find_easily qc, a[3,4]
  end
  
  def title
    quarter_code.name + " " + year.to_s
  end
  
  def self.current_and_future_quarters(limit = nil, current_qtr = nil)
    first_day_cmp = !current_qtr.is_a?(Quarter) ? Time.now : current_qtr.first_day
    Quarter.find(:all, :conditions => [ "first_day >= ?", first_day_cmp ], :limit => limit).sort
  end
  
  def self.future_quarters(limit = nil, current_qtr = nil)
    first_day_cmp = !current_qtr.is_a?(Quarter) ? Time.now : current_qtr.first_day
    Quarter.find(:all, :conditions => [ "first_day >= ?", first_day_cmp ], :limit => limit).sort
  end

  # Returns an array of past quarters going back for as many quarters as requested (defaults to 10 quarters), excluding the current quarter.
  def self.past_quarters(limit = 10)
    past_quarters = []
    q = Quarter.current_quarter.prev
    for i in 1..limit
      past_quarters << q
      q = q.prev
    end
    past_quarters
  end

  # Returns the current Quarter, based on quarter start dates.
  def self.current_quarter
    #@current_quarter ||= Quarter.find(:first, :conditions => [ "first_day < ?", Time.now ], :order => "first_day DESC") Remove instance valuable so it won't be cacheed until refresh the web server
    Quarter.find(:first, :conditions => [ "first_day < ?", Time.now ], :order => "first_day DESC")
  end
  
  # Returns true if this quarter is the current_quarter.
  def current_quarter?
    self == Quarter.current_quarter
  end

  def <=>(o)
    year_compare = self.year <=> o.year rescue 0
    return year_compare unless year_compare == 0
    qtr_code_compare = self.quarter_code_id <=> o.quarter_code_id rescue 0
    return qtr_code_compare
  end
  
  # Determines the next Quarter in the calendar
  def next
    next_qtr_code = quarter_code_id == 4 ? 1 : quarter_code_id + 1
    next_year = quarter_code_id == 4 ? year + 1 : year
    Quarter.find_easily(next_qtr_code, next_year)
  end
  
  # Determines the previous Quarter in the calendar
  def prev
    prev_qtr_code = quarter_code_id == 1 ? 4 : quarter_code_id - 1
    prev_year = quarter_code_id == 1 ? year - 1 : year
    Quarter.find_easily(prev_qtr_code, prev_year)
  end
  
  # Finds a Quarter object by quarter_code and year. Automatically creates a new Quarter record if it can't be found.
  def self.find_easily(quarter_code, year)
    q = Quarter.find_by_quarter_code_id_and_year(quarter_code, year)
    q ||= Quarter.create(:quarter_code_id => quarter_code, :year => year, :first_day => guess_first_day(quarter_code, year))
    q
  end

  # Returns all students who were placed in service learning positions for this Quarter.
  def service_learners
    service_learning_positions.collect(&:placements).flatten.collect(&:person).compact.uniq
  end
  
  # Returns all students who are enrolled in service learning quarters for this Quarter.
  def potential_service_learners
    service_learning_courses.collect(&:enrollees)
  end

  # Finds all courses in the time schedule for this quarter that have the "ts_research" flag set to "Y".
  def research_courses
    Course.find :all, :conditions => { :ts_year => year, :ts_quarter => quarter_code, :ts_research => true }
  end

  # Finds all courses in the time schedule for this quarter that have the "ts_service" flag set to "Y".
  def service_courses
    Course.find :all, :conditions => { :ts_year => year, :ts_quarter => quarter_code, :ts_service => true }
  end

  # Returns true if the date provided falls after the first day of this quarter and before the first day of the next quarter.
  def include?(date)
    date >= start_date && date < self.next.date
  end

  # Returns the academic year of this quarter, which is returned as a string like "2008-2009." For purposes of this method,
  # Summer is the first quarter of the academic year. So Summer 2008 will return "2008-2009" and Spring 2008 will return "2007-2008".
  def academic_year
    academic_year = case quarter_code_id
    when 1
      "#{year-1}-#{year}"
    when 2
      "#{year-1}-#{year}"
    when 3
      "#{year}-#{year+1}"
    when 4
      "#{year}-#{year+1}"
    end
    academic_year
  end

  # Returns the quarter where the specified date falls by calling the same method on StudentCalendarQuarter. Returns the
  # Quarter object instead of a StudentCalendarQuarter object.
  # If not found in StudentCalendarQuarter, try to workaround to guess from quarter's first day, added 02-01-2021
  def self.find_by_date(qdate)
    scq = StudentCalendarQuarter.find_by_date(qdate) 
    # scq.quarter rescue nil
    if scq
      scq.quarter
    else
      self.find(:first, :conditions => [":qdate >= first_day AND year = :qyear", {:qdate => qdate.to_s(:db), :qyear => qdate.year}]) rescue nil
    end
  end

  protected
  
  def self.guess_first_day(quarter_code, year)
    first_day = case quarter_code
    when 1
      "#{year}-01-01"
    when 2
      "#{year}-04-01"
    when 3
      "#{year}-06-01"
    when 4
      "#{year}-10-01"
    end
    first_day
  end
  
end
