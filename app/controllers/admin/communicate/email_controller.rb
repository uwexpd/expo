class Admin::Communicate::EmailController < Admin::BaseController
  before_filter :get_recipients, :except => [ :apply_template ]

  def write
    session[:return_to_after_email_queue] = request.referer
    session[:breadcrumbs].add "Compose Message"
    
    @recipient_sample = @recipients.try(:first)
    @recipient_sample_num = 0
  end

  def queue
    if params[:update_email_template]
      @template = EmailTemplate.find params[:email][:template_id]
      @template.update_attribute(:body, params[:email][:body])
    end
    if params[:create_email_template] && params[:new_email_template_name]
      @email_template = EmailTemplate.new(:name => params[:new_email_template_name], 
                                      :body => params[:email][:body], 
                                      :subject => params[:email][:subject],
                                      :from => params[:email][:from])
      unless @email_template.save
        session[:breadcrumbs].add "Compose Message"
        return render :action => "write"
      end
    end
    @recipients.each do |r|
      person_id = r.is_a?(Person) ? r.id : r.person.id rescue nil
      command_after_delivery = nil
      if params[:html_format].nil? || params[:html_format]==false
        template = TemplateMailer.create_message(r, params[:email][:from], params[:email][:subject], params[:email][:body])
      else 
        template = TemplateMailer.create_html_message(r, params[:email][:from], params[:email][:subject], params[:email][:body])
      end
      EmailQueue.queue(person_id, template, nil, command_after_delivery, nil, r)
    end
    flash[:notice] = "Successfully queued messages."
    return redirect_to admin_communicate_email_queue_index_url if EmailQueue.messages_waiting?
    redirect_to request.referer
  end

  def apply_template
    @email_template = EmailTemplate.find params[:email_template_id]
    respond_to do |format|
      format.js
    end
  end

  def resample_placeholder_codes
    @recipient_sample_num = params[:new_sample_num].to_i rescue 0
    respond_to do |format|
      format.js
    end
  end
  
  def sample_preview
    @recipient_sample_num = params[:current_sample_num].to_i rescue 0
    @recipient_sample = @recipients[@recipient_sample_num] rescue @recipients.first rescue nil
    respond_to do |format|
      format.js
    end
  end

  protected
  
  # Extracts an array of recipient objects. These objects MUST have a "person" attribute or be a Person, otherwise they won't be added.
  def get_recipients
    unless params[:select]
      flash[:error] = "You must select at least one recipient to send the message to."
      return redirect_to :back
    end
    @recipients = []
    params[:select].each do |obj_type,obj_hash|
      obj_hash.each do |obj_id,val|
        obj = obj_type.constantize.find(obj_id)  #eval("#{obj_type}.find(#{obj_id})")
        unless params[:group_variant].blank?
          recipients = obj.instance_eval(params[:group_variant])
        else
          recipients =  case obj.class.to_s
                        when "OrganizationQuarter"      then obj.organization.contacts
                        when "Organization"             then obj.contacts
                        when "School"                   then obj.contacts
                        when "ServiceLearningCourse"    then obj.instructors
                        when "CommitteeMemberMeeting"   then obj.committee_member
                        when "CommitteeMemberQuarter"   then obj.committee_member
                        when "EventStaffPositionShift"  then obj.staffs
                        when "Population"               then obj.objects
                        when "PopulationGroup"          then obj.objects
                        else obj
                        end
        end
        unless params[:recipient_variant].blank?
           if params[:recipient_variant] == "required_mentors"
             recipients.to_a.each{ |r| @recipients << r.mentors.reject(&:approved?).select{|m| m.primary || m.meets_minimum_qualification?} }
           else
             if obj_type == "ServiceLearningCourse" && recipients.blank?
                 # deal with whe no instructors for service learning course
                @recipients << obj.instance_eval((params[:recipient_variant].split(".").second))
             else
               recipients.to_a.each{ |r| @recipients << r.instance_eval(params[:recipient_variant]) }
             end
           end
        else
          @recipients << recipients
        end
      end
    end
    @recipients.flatten!
    @recipients.compact!
    @recipients
  end

end
