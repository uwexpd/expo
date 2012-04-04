module Admin::ApplyHelper
  
  def print_status(app)
    if app.current_status == nil
      status = "Not Started"
      desc = "The applicant tried to login but was did not meet restrictions, or received an error."
    elsif app.current_status.name == 'in_progress'
      status = "In Progress (#{app.current_page.offering_page.title || "Welcome"})" rescue "unknown - missing current page"
      desc = app.current_status.description
    else
      status = app.current_status.name.titleize
      desc = app.current_status.description
    end
      %(<a title="#{desc}" class="tooltip">#{status}</a>)
  end
  
  def print_public_status(app)
    if app.current_status == nil
      s = "nothing"
    else
      s = app.current_status.public_title
    end
      s
  end
  
  def status_email_view_links(application_status_type, offering, popup = true, options = {}, intro_text = "View e-mails:")
		links = []
    unless offering.nil? || application_status_type.nil? || application_status_type.emails_for(offering.id).empty?  
			application_status_type.emails_for(offering.id).each do |offering_status_email|
			  links << link_to(offering_status_email.send_to, 
			                    admin_communicate_template_path(offering_status_email.email_template), 
      						        :popup => popup)
		  end
		  "<span class='#{options[:class]}'>#{intro_text} #{links.join(' | ')}</span>"
		end
  end

  def status_email_view_links_array(application_status_type_name, offering, popup = true, options = {})
    links = []
    status_type = ApplicationStatusType.find_by_name(application_status_type_name)
    offering_status = OfferingStatus.find_or_create_by_offering_id_and_application_status_type_id(offering, status_type.id)
    emails = status_type.emails_for(offering.id)
    if emails.empty?
      links << "<small class='grey'>No e-mails are defined for this status change. 
                #{link_to "Add one.", new_offering_status_email_path(offering, offering_status), :popup => popup}</small>"
    else
      emails.each do |email|
  			link = link_to("to " + email.send_to, admin_communicate_template_path(email.email_template), :popup => popup)
        link << "<small class='grey'> - Updated #{time_ago_in_words(email.email_template.updated_at) rescue "unknown"} ago 
  				        by #{email.email_template.updater.person.fullname rescue "unknown"}</small>"
  		  links << link
		  end
      links << "<small class='grey'>#{link_to "Add, edit, and delete status e-mails for ths status", 
                offering_status_emails_path(offering, offering_status), :popup => popup}</small>"
	  end
		links
  end
  
end
