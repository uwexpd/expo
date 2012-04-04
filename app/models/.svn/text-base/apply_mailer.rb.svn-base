class ApplyMailer < ActionMailer::Base
  include ActionController::UrlWriter

  def status_update(application_for_offering, email_template, recipients, sent_at = Time.now, 
                    link = apply_url(:host => CONSTANTS[:base_url_host], 
                                      :offering => application_for_offering.offering),
                    availability_link = apply_url(:host => CONSTANTS[:base_url_host], 
                                                  :offering => application_for_offering.offering) + "/availability",
                    cc_to_feedback_person = false)
    @subject    = email_template.subject
    @subject.gsub!(/\%([a-z0-9_.]+)\%/) { |a| eval("application_for_offering.#{a.gsub!(/\%/,'')}") rescue nil }
    @body       = { :application_for_offering => application_for_offering, 
                    :text => email_template.body.to_s, 
                    :link => link,
                    :availability_link => availability_link }
    @from       = email_template.from
    @cc         = application_for_offering.final_feedback_person.email if cc_to_feedback_person && !application_for_offering.final_feedback_person.nil?
    @sent_on    = sent_at
    @headers    = {}
    @recipients = recipients
  end
  
  def mentor_status_update(mentor, email_template, recipients, sent_at = Time.now, link = mentor_url(:host => CONSTANTS[:base_url_host]))
    @subject    = email_template.subject.to_s
    @subject.gsub!(/\%mentee.([a-z0-9_.]+)\%/) { |a| eval("mentor.application_for_offering.person.#{a.gsub!(/\%mentee./,'').gsub!(/\%/,'')}") rescue nil }
    @body       = { :mentor => mentor,
                    :mentee => mentor.application_for_offering.person,
                    :text => email_template.body.to_s, 
                    :link => link }
    @from       = email_template.from
    @sent_on    = sent_at
    @headers    = {}
    @recipients = recipients
  end
  
  def group_member_status_update(group_member, email_template, recipients, sent_at = Time.now, link = apply_url(:host => CONSTANTS[:base_url_host], :offering => offering))
    @subject    = email_template.subject.to_s
    @body       = { :group_member => group_member,
                    :text => email_template.body.to_s,
                    :link => link }
    @from       = email_template.from
    @sent_on    = sent_at
    @headers    = {}
    @recipients = recipients
  end

  def mentor_thank_you(mentor, email_template, recipients, sent_at = Time.now, link = mentor_url(:host => CONSTANTS[:base_url_host]))
    @subject    = email_template.subject.to_s
    @subject.gsub!(/\%mentee.([a-z0-9_.]+)\%/) { |a| eval("mentor.application_for_offering.person.#{a.gsub!(/\%mentee./,'').gsub!(/\%/,'')}") rescue nil }
    @body       = { :mentor => mentor,
                    :mentee => mentor.application_for_offering.person,
                    :text => email_template.body.to_s, 
                    :link => link }
    @from       = email_template.from
    @sent_on    = sent_at
    @headers    = {}
    @recipients = recipients
  end
  
  
  def mentor_no_email_warning(mentor, recipients, sent_at = Time.now)
    @subject    = "Mentor with no e-mail access notification"
    @body       = { :mentor => mentor,
                    :mentee => mentor.application_for_offering.person }
    @from       = "expohelp@u.washington.edu"
    @sent_on    = sent_at
    @recipients = recipients
  end

  def interviewer_message(offering_interviewer, email_template, offering, 
                          link = interviewer_url(:host => CONSTANTS[:base_url_host], :offering => offering),
                          invite_link = interviewer_url(:host => CONSTANTS[:base_url_host], :offering => offering) + "/welcome")
    @subject    = email_template.subject
    @body       = { :offering_interviewer => offering_interviewer, 
                    :text => email_template.body.to_s, 
                    :link => link,
                    :invite_link => invite_link }
    @from       = email_template.from
    @sent_on    = Time.now
    @headers    = {}
    @recipients = offering_interviewer.person.email
  end

  def reviewer_message(offering_reviewer, email_template, offering, link = reviewer_url(:host => CONSTANTS[:base_url_host], 
                                                                          :offering => offering))
    @subject    = email_template.subject
    @body       = { :offering_reviewer => offering_reviewer, 
                    :text => email_template.body.to_s, 
                    :link => link }
    @from       = email_template.from
    @sent_on    = Time.now
    @headers    = {}
    @recipients = offering_reviewer.person.email
  end


  def templated_message(person, email_template, recipients, link)
    @subject    = email_template.subject
    @body       = { :person => person, 
                    :text => email_template.body.to_s, 
                    :link => link }
    @from       = email_template.from
    @sent_on    = Time.now
    @headers    = {}
    @recipients = recipients
  end

end
