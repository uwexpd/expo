class PipelineStudentInfo < ActiveRecord::Base
  set_table_name "pipeline_student_info"
  
  belongs_to :person
  
  validates_presence_of :how_did_you_hear, :teaching_career, :person_id, :if => :require_validations?
  
  validates_inclusion_of :fulfill_mit, :apply_masters, :in => [true, false], :if => :require_validations?
  
  validates_acceptance_of :downloaded_pdf, :message => "is not checked, please remember to download the background check PDF", :if => :require_validations?
  
  attr_accessor :downloaded_pdf
  
  attr_accessor :require_validations
  
  def require_validations?
    require_validations
  end
  
end