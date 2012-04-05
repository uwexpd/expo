class ServiceLearningMailer < ActionMailer::Base

  def registration_complete(placement, sent_at = Time.now)
    @subject    = 'Service Learning Registration Complete'
    @body       = { :placement => placement }
    @recipients = placement.person.email
    @from       = 'serve@u.washington.edu'
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def bothell_registration_complete(placement, sent_at = Time.now)
    @subject    = 'Community-based Learning Placement Registration Complete'
    @body       = { :placement => placement }
    @recipients = placement.person.email
    @from       = 'cblr@uw.edu'
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def pipeline_registration_complete(placement, sent_at = Time.now)
    @subject    = 'Pipeline Registration Complete'
    @body       = { :placement => placement }
    @recipients = placement.person.email
    @from       = 'pipeline@u.washington.edu'
    @sent_on    = sent_at
    @headers    = {}
  end
end
