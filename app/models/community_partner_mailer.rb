class CommunityPartnerMailer < ActionMailer::Base

  def service_learning_login_link(organization_contact, sent_at = Time.now)
    @subject    = "Service-learning access for #{organization_contact.organization.name}"
    @body       = { :organization_contact => organization_contact,
                    :link => organization_contact.login_url
                   }
    @recipients = organization_contact.person.email
    @from       = 'serve@u.washington.edu'
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def community_partner_login_link(organization_contact, unit, sent_at = Time.now)
    @subject    = "#{unit.title} access for #{organization_contact.organization.name}"
    @body       = { :organization_contact => organization_contact,
                    :unit => unit,
                    :link => organization_contact.login_url
                   }
    @recipients = organization_contact.person.email
    @from       = unit.email
    @sent_on    = sent_at
    @headers    = {}
  end
end
