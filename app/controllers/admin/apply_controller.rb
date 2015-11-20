class Admin::ApplyController < Admin::BaseController
  before_filter :add_to_breadcrumbs
  before_filter :fetch_offering, :except => [:approve, :finaid_approve, :disberse, :all]
  before_filter :fetch_apps, :except => [:approve, :finaid_approve, :disberse, :all, :add_to_reviewer, :drop_from_reviewer, :scored_selection, :list, :assign_session, :create]
  before_filter :fetch_confirmers, :only => [:invited_guests, :nominated_mentors, :theme_responses, :proceedings_requests, :scored_selection]

  uses_charts

  def auto_complete_model_for_person_fullname
    @result = {}
    query = params[:person][:fullname].downcase
    all = (@apps + @apps.collect(&:group_members)).flatten
    all.each do |a|
      count = a.fullname.downcase.scan(query).size
      @result[a] = count unless count.zero?
    end
    @result = @result.sort_by{ |k,v| v }.reverse[0..8]
    # 
    # @result = @apps.find_all{|a| a.fullname.downcase.include?()}[0..8]
    # @result << @apps.collect(&:group_members).flatten.find_all{|g| g.fullname.downcase.include?(params[:person][:fullname].downcase)}[0..8]
    # @result.flatten!
    render :partial => "auto_complete", :object => @result, :locals => { :highlight_phrase => params[:person][:fullname] }
  end

  def index
	  @offering_graph_object = open_flash_chart_object_and_div_name( '100%', '100%', 
	                            offering_line_graph_applicants_charts_path(:o=>@offering.id),
	                            true,
	                            "open-flash-chart.swf",
	                            "open-flash-chart.swf")
    session[:breadcrumbs].add "Manage"
  end

  def create
    unless request.put?
      flash[:error] = "Only PUT requests are allowed."
      return redirect_to :back
    end
    if params[:offering_id] && params[:person_id]
      offering = Offering.find(params[:offering_id])
      application = offering.application_for_offerings.new
      person = Person.find params[:person_id]
      application.person_id = person.try(:id)
      if application.save
        flash[:notice] = "Successfully created a new application for #{person.fullname}"
        return redirect_to :action => "show", :offering => offering, :id => application
      else
        flash[:error] = "An error occurred."
        return redirect_to :back
      end
    else
      flash[:error] = "You must specify an offering ID and a person ID."
      return redirect_to :back
    end
  end

  def all
    redirect_to offerings_url
  end
  
  def list
    session[:breadcrumbs].add "Applicant List"
  end

  def show
    if request.post?
      if params[:id] == 1 || params[:id].blank?
        flash[:error] = "Please select an application from the drop-down list when using the search tool."
        return redirect_to :back
      else
        return redirect_to :action => "show", :id => params[:id]
      end
    end 
    @app = @offering.application_for_offerings.find params[:id]
    session[:breadcrumbs].add "#{@app.fullname}"
    
    if params['section']
      respond_to do |format|
        format.html { return redirect_to :action => :show, :anchor => params[:section] }
        format.js   { return render :partial => "admin/apply/section/#{params[:section]}", :locals => { :admin_view => true } }
      end
    end
  end
  
  def convert_to_pdf
    @app = ApplicationForOffering.find params[:id]
    if params[:file]
      @file = @app.files.find(params[:file]).file
    elsif params[:mentor]
      @file = @app.mentors.find(params[:mentor]).letter
    end
    respond_to do |format|
      format.html { render :text => @file.process!(:convert_to_pdf) }
      format.js { 
        if @file.process!(:convert_to_pdf).success?
          render :partial => 'file', :locals => { :file => @file, :v => :pdf, :f => @file.pdf }, :status => 200
        else
          render :text => "Error: Could not convert to PDF", :status => 500
        end
      }
    end
  end

  def view
    @app = ApplicationForOffering.find params[:id]
    version = params[:version].nil? ? :original : params[:version].to_sym
    if params[:file]
      file = @app.files.find(params[:file]).file.versions[version]
      file_path = File.join(RAILS_ROOT, 'files', file.public_path)
      type = file.content_type
      filename = file.public_filename
    elsif params[:mentor]
      file = @app.mentors.find(params[:mentor]).letter.versions[version]
      file_path = File.join(RAILS_ROOT, 'files', file.public_path)
      type = file.content_type
      filename = file.public_filename
    end
    disposition = params[:disposition] == 'inline' ? 'inline' : 'attachment'
    send_file file_path, :disposition => disposition, :type => (type || "text"), :filename => filename unless file_path.nil?
  end
  
  def show2
    @app = ApplicationForOffering.find params[:id]
    session[:breadcrumbs].add "Detail"
  end

  def history
    @app = ApplicationForOffering.find params[:id]
    session[:breadcrumbs].add "History"
  end
  
  def edit
    @app = @offering.application_for_offerings.find params[:id]
    @app_pages = []   
    for page in @app.pages
      question_types = page.offering_page.questions.collect(&:display_as).uniq.to_set
      attribute_types = page.offering_page.questions.collect(&:attribute_to_update).uniq.to_set
      unless ["files","mentors","application_type","application_category"].any? {|type| question_types.include?(type) } || ["Abstract"].any? {|attribute| attribute_types.include?(attribute) }
        @app_pages << page
      end
      
    end
    
    session[:breadcrumbs].add "#{@app.fullname}", {:action => 'show', :id => @app}
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @app = ApplicationForOffering.find params[:id]
    anchor = params[:section] if params[:section]
    if params['app'] || params['user_application']
      unless params['app']['new_status'].blank?
        @app.set_status(params['app']['new_status'], false, {:force => true, :note => params['app']['new_status_note']}) 
        params['app'].delete('new_status')
        params['app'].delete('new_status_note')
        @update_application_status = true
      else
        params['app'].delete('new_status') if params['app']['new_status']
      end
      @app.add_reviewer params['app']['new_reviewer'] unless params['app']['new_reviewer'].blank?
      if params['app']['special_notes']
        @app.update_attribute('special_notes', params['app']['special_notes'])
        flash[:notice] = "Application notes saved."
        anchor = "review_committee"
      end
      if @app.update_attributes(params['app']) && (params['user_application'] && @app.update_attributes(params['user_application']))
        flash[:notice] = "Application changes saved."
        if Thread.current['pdf_conversion_error']
          flash[:error] = Thread.current['pdf_conversion_error']
          Thread.current['pdf_conversion_error'] = nil
        end
      end
    end        
    if params[:remove_group_member]
      @app.group_members.find(params[:remove_group_member]).destroy
      anchor = "group_members"
    end
    if params[:resend_group_member]
      if @app.group_members.find(params[:resend_group_member]).send_validation_email
        flash[:notice] = "Successfully re-sent verification e-mail."
      else
        flash[:error] = "Could not send verification e-mail."
      end
      anchor = "group_members"
    end
    session[:return_to_after_email_queue] = request.referer
    redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?

    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @app, :anchor => anchor }
      format.js   { }
    end
  end
  
  def approve
    session[:breadcrumbs].add "Approve Awards"
    @offerings = current_user.offerings_with_approval_access
    if request.post?
      params[:select].each do |app_id, attributes|
        app = ApplicationForOffering.find(app_id)
        app.dean_approve_awards(@current_user) if params[:commit]
        @offering = app.offering
      end
      flash[:notice] = "Saved approvals successfully. Thank you."
      redirect_to_action = params[:redirect_to_action] || "approve"
      redirect_to :action => redirect_to_action
    end
  end

  def finaid_approve
    session[:breadcrumbs].add "Financial Aid Eligibility Approval"
    @offerings = current_user.offerings_with_financial_aid_approval_access
    if request.post?
      params[:award].each do |award_id, attributes|
        award = ApplicationAward.find(award_id)
        award.update_attributes(attributes)
        # award.application_for_offering.set_status "awaiting_disbursement" if params[:commit]
        award.application_for_offering.update_attribute(:financial_aid_approved_at, Time.now) if params[:commit]
        @offering = award.application_for_offering.offering
      end
      EmailContact.log @offering.disbersement_approver.person.id, 
                      ApplyMailer.deliver_templated_message(@offering.disbersement_approver.person, 
                      EmailTemplate.find_by_name("disbersement approval request"), 
                      @offering.disbersement_approver.person.email, 
                      "http://#{CONSTANTS[:base_system_url]}/admin/apply/disberse") if params[:commit]
      flash[:notice] = "Saved financial aid eligibility approvals. Thank you."
      redirect_to_action = params[:redirect_to_action] || "finaid_approve"
      redirect_to :action => redirect_to_action
    end
  end
  
  def disberse
    session[:breadcrumbs].add "Disburse Award Funds"
    @offerings = current_user.offerings_with_disbersement_approval_access
    if request.post?
      params[:award].each do |award_id, attributes|
        award = ApplicationAward.find(award_id)
        award.update_attributes(attributes)
        # award.application_for_offering.set_status "finalized" if params[:commit]
        award.application_for_offering.update_attribute(:disbursed_at, Time.now) if params[:commit]
        @offering = award.application_for_offering.offering
      end
      flash[:notice] = "Saved disbursement information. Thank you."
      #redirect_to_action = params[:redirect_to_action] || "disberse"
      #redirect_to :action => redirect_to_action
    end
    
    respond_to do |format|
      format.html
      format.xls { render :action => 'disberse', :layout => 'basic' } # disberse.xls.erb
    end
  end
  
  def availability
    session[:breadcrumbs].add "Availability"
    @app = ApplicationForOffering.find params[:id]
  end
    
  def print_availabilities
    @apps = @offering.application_for_offerings.select{|a| a.responded_with_availability? }
    render :action => "print_availabilities", :layout => 'print_only'
  end

  def mass_update
    if params[:approve_review]
      params[:approve_review].each do |app_id,new_status|
        ApplicationForOffering.find(app_id).set_status(new_status, false) unless new_status.blank?
      end
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
    end
    redirect_to_action = params[:redirect_to_action] || "index"
    redirect_to :action => redirect_to_action
  end
  
  def mass_status_change
    if params[:new_status] && params[:select]
      params[:select].each do |klass, select_hash|
        select_hash.each do |app_id,v|
          ApplicationForOffering.find(app_id).set_status(params[:new_status], false, :force => true) unless params[:new_status].blank?
        end
      end
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
    end
    redirect_to_action = params[:redirect_to_action] || "index"
    redirect_to session[:return_to_after_email_queue] || request.referer || url_for(:action => redirect_to_action)
  end
  
  def mass_assign_reviewers
    session[:return_to_after_email_queue] = request.referer
    if params[:new_status] && params[:select] && params[:reviewer]
      params[:select].each do |klass, select_hash|
        select_hash.each do |app_id,v|
          params[:reviewer].each do |reviewer_id,v|
            app = ApplicationForOffering.find(app_id)
            if @offering.review_committee.nil?
              app.add_reviewer(reviewer_id) # add an offering_reviewer
            else
              app.add_reviewer(CommitteeMember.find(reviewer_id)) # add a review committee member
            end
          end
        end
      end
    end
    mass_status_change and return if params[:change_status]
    redirect_to_action = params[:redirect_to_action] || "index"
    redirect_to session[:return_to_after_email_queue] || url_for(:action => redirect_to_action)
  end
  
  # To pass a reviewer to *remove* at the same time, encode the element_id like this: "applicant_[old_reviewer_id]_[applicant_id]"
  def add_to_reviewer
    if params[:id] && params[:reviewer_id]
      app_id = params[:id][/^[^_\-](?:[A-Za-z0-9\-\_]*)[_](.*)$/,1]
      @applicant = ApplicationForOffering.find(app_id)
      @reviewer = CommitteeMember.find(params[:reviewer_id])
      render :text => "error", :status => 406 and return false unless @applicant.add_reviewer(@reviewer)
      if params[:switch]
        old_reviewer_id = params[:id][/^[^_\-](?:[A-Za-z0-9\-\_]*)[_]((\d*)[_](\d*)$)/,2]
        if @old_reviewer = CommitteeMember.find(old_reviewer_id)
          @applicant.drop_reviewer(@old_reviewer)
        end
      end
    end
  end

  # Drop an applicant from a reviewer. Encode the element_id like this: "applicant_[old_reviewer_id]_[applicant_id]"
  def drop_from_reviewer
    if params[:id]
      app_id = params[:id][/^[^_\-](?:[A-Za-z0-9\-\_]*)[_](.*)$/,1]
      old_reviewer_id = params[:id][/^[^_\-](?:[A-Za-z0-9\-\_]*)[_]((\d*)[_](\d*)$)/,2]
      @applicant = ApplicationForOffering.find(app_id)
      if @old_reviewer = CommitteeMember.find(old_reviewer_id)
        @applicant.drop_reviewer(@old_reviewer)
      end
    end
  end
  
  def reload_applicants
    @applicants = @offering.application_for_offerings.with_status("approved").first 10
    @applicants.sort!{|x,y| x.mentor_department <=> y.mentor_department rescue -1 } if params[:sort] == 'department'
    @applicants.sort!{|y,x| x.mentor_department <=> y.mentor_department rescue -1 } if params[:sort] == 'department_reverse' rescue false
    render :partial => "applicants", :locals => { :applicants => @applicants }
  end

  def reload_reviewers
    member_type = CommitteeMemberType.find(params[:member_type_id])
    @members = @offering.review_committee.members.of_type(member_type).select{|m| m.active?}
    @members.sort!{|y,x| x.applications_for_review.count <=> y.applications_for_review.count } if params[:sort] == 'count'
    @members.sort!{|x,y| x.applications_for_review.count <=> y.applications_for_review.count } if params[:sort] == 'count_reverse'
    @members.sort!{|x,y| x.department <=> y.department rescue -1 } if params[:sort] == 'department' rescue false
    @members.sort!{|y,x| x.department <=> y.department rescue -1 } if params[:sort] == 'department_reverse' rescue false
    render :partial => "reviewers", :locals => { :member_type => member_type, :members => @members }
  end

  def assign_session
    if params[:app][:offering_session_id]
#      @session = @offering.sessions.find(params[:app][:offering_session_id]) rescue nil
      @app = ApplicationForOffering.find params[:id]
      @app.update_attributes(params[:app])
    end
    render(:partial => "admin/apply/section/session", :layout => false) and return
  end

  def assign_review_decision
    @app = @offering.application_for_offerings.find(params[:assign_review_decision][:app_id]) rescue nil
    @review_decision = @offering.application_review_decision_types.find(params[:assign_review_decision][:decision_type_id]) rescue nil

    if @app.nil?
      error = "Could not find an application with that ID."
    elsif @review_decision.nil?
      error = "Could not find review decision type with that ID."
    elsif @app.update_attribute(:application_review_decision_type_id, @review_decision.id) && @app.set_status("reviewed")
      flash[:notice] = "Successfully assigned review decision to application."
    else
      error = "Error assigning review decision to application."
    end
    respond_to do |format|
      if error
        format.html { redirect_to :back }
        format.js   { render :text => error, :status => 400 }
      else
        format.html { redirect_to :back }
        format.js   { render :partial => "mini_details" }
      end
    end
  end

  def update_flash
    respond_to do |format|
      format.js
    end
  end

  def mass_email
    params[:select].each do |app_id,v|
      ApplicationForOffering.find(app_id).send_email(params[:mass_email][:email_template_id], false, params[:mass_email][:send_to])
    end
    session[:return_to_after_email_queue] = request.referer
    redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
  end
  
  def accept_interview_decisions
    if params[:dean_approver_uw_netid]
      dean_approver = PubcookieUser.authenticate(params[:dean_approver_uw_netid])
      @offering.update_attribute(:dean_approver_id, dean_approver.id)
    end
    if params[:new_status] && params[:select]
      if params[:application_for_offering]
        ApplicationForOffering.update params[:application_for_offering].keys, params[:application_for_offering].values
      end
      params[:select].each do |app_id,v|
        app = ApplicationForOffering.find(app_id)
        app.set_status params[:new_status] unless params[:new_status].blank?
      end
      EmailContact.log dean_approver.person.id, 
          ApplyMailer.deliver_templated_message(dean_approver.person, 
          EmailTemplate.find_by_name("dean approval request"), 
          dean_approver.person.email, 
          "https://#{CONSTANTS[:base_system_url]}/admin/apply/approve")
      flash[:notice] = "Request for dean approvals sent."
    end
    redirect_to request.referer
  end
  
  def notify_dean
    if params[:dean_approver_uw_netid]
      dean_approver = PubcookieUser.authenticate(params[:dean_approver_uw_netid])
      @offering.update_attribute(:dean_approver_id, dean_approver.id)
      EmailContact.log dean_approver.person.id, 
          ApplyMailer.deliver_templated_message(dean_approver.person, 
          EmailTemplate.find_by_name("dean approval request"), 
          dean_approver.person.email, 
          "https://#{CONSTANTS[:base_system_url]}/admin/apply/approve")
      flash[:notice] = "Request for dean approvals sent."
    end
    if params[:new_status] && params[:select]
      params[:select].each do |klass, select_hash|
        select_hash.each do |app_id,v|
          ApplicationForOffering.find(app_id).set_status(params[:new_status], false, :force => true) unless params[:new_status].blank?
        end
      end
    end
    redirect_to request.referer    
  end
  
  def send_to_financial_aid
    if params[:financial_aid_approver_uw_netid]
      financial_aid_approver = PubcookieUser.authenticate(params[:financial_aid_approver_uw_netid])
      @offering.update_attribute(:financial_aid_approver_id, financial_aid_approver.id)
    end
    if params[:disbersement_approver_uw_netid]
      disbersement_approver = PubcookieUser.authenticate(params[:disbersement_approver_uw_netid])
      @offering.update_attribute(:disbersement_approver_id, disbersement_approver.id)
    end
    # if params[:new_status] && params[:select]
    #   params[:select].each do |app_id,v|
    #     app = ApplicationForOffering.find(app_id)
    #     app.set_status params[:new_status] unless params[:new_status].blank?
    #     @offering = app.offering
    #   end
    EmailContact.log @offering.financial_aid_approver.person.id, 
        ApplyMailer.deliver_templated_message(@offering.financial_aid_approver.person, 
        EmailTemplate.find_by_name("financial aid approval request"), 
        @offering.financial_aid_approver.person.email, 
        "https://#{CONSTANTS[:base_system_url]}/admin/apply/finaid_approve")
    flash[:notice] = "Request for financial aid approvals sent."
    @offering.update_attribute(:financial_aid_approval_request_sent_at, Time.now)
    # end
    redirect_to request.referer
  end
  
  # def mark_complete
  #   phase = OfferingAdminPhase.find(params[:phase_id])
  #   phase.complete = true
  #   phase.save
  #   render :partial => "admin/apply/phase", :object => phase
  # end
  # 
  # def mark_incomplete
  #   phase = OfferingAdminPhase.find(params[:phase_id])
  #   phase.complete = false
  #   phase.save
  #   render :partial => "admin/apply/phase", :object => phase
  # end
  # 
  # def phase
  #   @phase = OfferingAdminPhase.find params[:id]
  #   session[:breadcrumbs].add @phase.name
  # 
  #   if params[:tasks]
  #     params[:tasks].each do |task,values|
  #       @phase.tasks.find(task).update_attributes(values)
  #     end
  #     if request.xhr?
  #       render :partial => "task", :collection => @phase.tasks.sort and return
  #     end
  #   end
  # end
  # 
  # def complete_phase
  #   @phase = OfferingAdminPhase.find params[:id]
  #   @phase.update_attribute :complete, true
  #   @offering.current_offering_admin_phase = @phase.next
  #   @offering.save
  #   redirect_to :action => "phase", :id => @phase.next
  # end
  # 
  # def switch_to_phase
  #   @phase = OfferingAdminPhase.find params[:id]
  #   @offering.current_offering_admin_phase = @phase
  #   @offering.save
  #   redirect_to :action => "phase", :id => @phase
  # end
  # 
  # 
  # def new_phase_task
  #   @phase = OfferingAdminPhase.find params[:id]
  #   if params[:new_phase_task]
  #     new_task = @phase.tasks.create params[:new_phase_task]
  #     flash[:notice] = "Added task '#{new_task.title}'."
  #   end
  #   redirect_to :action => "phase", :id => @phase
  # end
  # 
  # def remove_phase_task
  #   @phase = OfferingAdminPhase.find params[:id]
  #   if params[:task_id]
  #     removed_task = @phase.tasks.find(params[:task_id]).destroy
  #     flash[:notice] = "Removed task '#{removed_task.title}'."
  #   end
  #   redirect_to :action => "phase", :id => @phase
  # end
  # 
  # def phase_task
  #   @phase_task = OfferingAdminPhaseTask.find params[:id]
  #   @task = @phase_task
  #   @phase = @phase_task.offering_admin_phase
  #   session[:breadcrumbs].add "#{@phase.name}", {:action => 'phase', :id => @phase}
  #   session[:breadcrumbs].add @phase_task.title
  #   
  #   respond_to do |format|
  #     format.html
  #     format.js
  #   end
  # end
  # 
  # def complete_phase_task
  #   @phase_task = OfferingAdminPhaseTask.find params[:id]
  #   @task = @phase_task
  #   @phase = @phase_task.offering_admin_phase
  #   @task.update_attribute(:complete, true)
  #   respond_to do |format|
  #     format.html { redirect_to :action => "phase_task", :id => @task }
  #     format.js
  #   end    
  # end
  # 
  # def uncomplete_phase_task
  #   @phase_task = OfferingAdminPhaseTask.find params[:id]
  #   @task = @phase_task
  #   @phase = @phase_task.offering_admin_phase
  #   @task.update_attribute(:complete, false)
  #   respond_to do |format|
  #     format.html { redirect_to :action => "phase_task", :id => @task }
  #     format.js
  #   end        
  # end
  # 
  # def sort_phase_tasks
  #   @phase = OfferingAdminPhase.find params[:id]
  #   params[:phase_tasks].each_with_index do |id, index|
  #     @phase.tasks.update_all(['sequence=?', index+1], ['id=?', id])
  #   end
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  def interviews
    session[:breadcrumbs].add "Interviews"
    if params[:start_time] && params[:interviewer]
      @apps = @offering.applications_for_interview
      @apps.each do |a|
        start_time = params[:start_time]["#{a.id}"]
        interviewers = params[:interviewer]["#{a.id}"]
        if start_time && interviewers
          new_interview = @offering.interviews.create :start_time => start_time
          if new_interview.valid?
            new_interview.applicants.create :application_for_offering_id => a.id
            interviewers.each do |i|
              new_interview.interviewers.create :offering_interviewer_id => i
            end
            flash[:notice] = "Successfully created interview times"
          end
        end
      end
    end 
    @interviews = @offering.interviews.sort {|x,y| x.start_time <=> y.start_time }
  end

  def schedule
    @scheduler = OfferingInterviewScheduler.new(@offering)
    @apps = @offering.applications_for_interview
#    @apps.sort! { |x,y| @scheduler.timeslots_for(x).size <=> @scheduler.timeslots_for(y).size }
  end

  def add_interviewer
    
  end

  def send_interviewer_invite_emails
    return false if params[:email_template_id].nil?
    email_template = EmailTemplate.find(params[:email_template_id])
    params[:select].each do |klass, select_hash|
      select_hash.each do |object_id,v|
        @offering.interviewers.find_all{|r| r.id == object_id.to_i}.each do |i|
          if i.is_a?(OfferingInterviewer)
            if email_template.name.downcase.include?("interviewer invite")
              ufield = "invite_email_contact_history_id"
            elsif email_template.name.downcase.include?("interviewer interview times")
              ufield = "interview_times_email_contact_history_id"
            elsif email_template.name.downcase.include?("interviewer no interviews")
              ufield = "interview_times_email_contact_history_id"
            end
            if ufield
              command_after_delivery = "OfferingInterviewer.find(#{i.id}).update_attribute('#{ufield}', @email_contact.id)"
            end
          end
          EmailQueue.queue i.person.id,
                            ApplyMailer.create_interviewer_message(i, email_template.reload, @offering),
                            nil,
                            command_after_delivery
        end
      end
    end
    flash[:notice] = "Successfully queued e-mails to interviewers."
    session[:return_to_after_email_queue] = request.referer
    redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
    redirect_to :back
  end

  # This method can actually be used to send any emails to reviewers, not just invite emails.
  def send_reviewer_invite_emails
    return false if params[:email_template_id].nil?
    params[:select].each do |klass, select_hash|
      select_hash.each do |object_id,v|
        @offering.reviewers.find_all{|r| r.id == object_id.to_i}.each do |r|
          EmailQueue.queue r.person.id, 
                            ApplyMailer.create_reviewer_message(r, EmailTemplate.find(params[:email_template_id]), @offering)
        end
      end
    end
    flash[:notice] = "Successfully queued e-mails to reviewers."
    session[:return_to_after_email_queue] = request.referer
    redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
    redirect_to :back
  end

  def send_interviewer_interview_times_emails
    if params[:email_to_send] && params[:select]
      params[:select].each do |oi_id,v|
        oi = @offering.interviewers.find(oi_id)
        @offering_interviewer = oi
        EmailQueue.queue oi.person.id, ApplyMailer.create_interviewer_message(oi, EmailTemplate.find_by_name(params[:email_to_send]))
        oi.interview_times_email_sent_at = Time.now
        oi.save
      end
      flash[:notice] = "Successfully sent interview time emails to selected interviewers."
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
      redirect_to :action => "index"
    else
      flash[:error] = "You must specify at least one interviewer to email as well as the type of email to send."
      render :action => "index"
    end
  end

  def new_interview_timeblock
    if params[:new_interview_timeblock]
      flash[:notice] = "Added new interview timeblock." if @offering.interview_timeblocks.create params[:new_interview_timeblock]
    end
    redirect_to request.referer
  end
  
  def remove_interview_timeblock
    if params[:id]
      flash[:notice] = "Deleted interview timeblock." if @offering.interview_timeblocks.find(params[:id]).destroy
    end
    redirect_to request.referer
  end

  def new_interviewer
    if params[:new_interviewer]
      flash[:notice] = "Added new interviewer." if @offering.interviewers.create params[:new_interviewer]
    end
    redirect_to request.referer
  end
  
  def remove_interviewer
    if params[:id]
      flash[:notice] = "Deleted interviewer." if @offering.interviewers.find(params[:id]).destroy
    end
    redirect_to request.referer
  end
  
  def awardees
    @apps.reject! {|a| !a.awarded? }
    session[:breadcrumbs].add "Awardees"
    
    respond_to do |format|
      format.html # awardees.html.erb
      format.xls { render :action => 'awardees', :layout => 'basic' } # awardees.xls.erb
    end
  end

  def mentors
    @apps.reject! {|a| !a.awarded? }
    session[:breadcrumbs].add "Mentors"
    
    respond_to do |format|
      format.xls { render :action => 'mentors', :layout => 'basic' } # mentors.xls.erb
    end
  end
    

  def award_letter
    session[:breadcrumbs].add "Award Letters"
    @t = @offering.applicant_award_letter_template or raise ExpoException.new("No award letter template is defined.")
    find_selected_award_applications
  end

  def send_award_letters
    if params[:select]
      @apps = ApplicationForOffering.find(params[:select].values.collect(&:keys))
      @apps.each do |app|
        app.send_award_letter
      end
    else
      flash[:error] = "You must select at least one student first."
    end
    redirect_to :action => "award_letter"
  end

  def send_mentor_letters
    if params[:select]
      @apps = ApplicationForOffering.find(params[:select].values.collect(&:keys))
      @apps.each do |app|
        app.mentors.each do |mentor|
          mentor.send_mentor_letter
        end
      end
    else
      flash[:error] = "You must select at least one student first."
    end
    redirect_to :action => "award_letter"
  end

  def mentor_letter
    session[:breadcrumbs].add "Award Letters"
    @t = @offering.mentor_award_letter_template or raise ExpoException.new("No mentor letter template is defined.")
    find_selected_award_applications
  end

  def award_envelope
    session[:breadcrumbs].add "Award Envelopes"
    @paper = [24.13, 10.4775]
    find_selected_award_applications
  end

  def mentor_envelope
    session[:breadcrumbs].add "Mentor Envelopes"
    @paper = [24.13, 10.4775]
    find_selected_award_applications
  end

  def customize_award_letter
    session[:breadcrumbs].add "Customize Award Letter"
    @app = ApplicationForOffering.find(params[:id])
    
    if request.post?
      @app.update_attribute(:award_letter_text, params[:award_letter_text])
      redirect_to :action => "award_letter"
    end
  end

  def customize_mentor_letter
    session[:breadcrumbs].add "Customize Mentor Letter"
    @mentor = ApplicationMentor.find(params[:id])
    
    if request.post?
      @mentor.update_attribute(:mentor_letter_text, params[:mentor_letter_text])
      @mentor.person.update_attribute(:address_block, params[:address_block]) unless params[:address_block].blank?
      redirect_to :action => "award_letter"
    end
  end

  def abstracts
    @apps = @offering.application_for_offerings.with_status(params[:in_status]) if params[:in_status]
    @apps = @offering.applications_with_status(params[:with_status]) if params[:with_status]
    @apps = @offering.application_for_offerings.find(params[:select].values.collect(&:keys)) if params[:select]
    @apps = @apps.find_all{|a| a.application_type_id == params[:application_type_id].to_i} if params[:application_type_id]
    @apps = @apps.sort{|x,y| x.instance_eval(params[:order]) <=> y.instance_eval(params[:order]) rescue 0} if params[:order]
    respond_to do |format|
      format.pdf  { render :layout => 'default' }
    end
  end
  
  def abstract
    @app = @offering.application_for_offerings.find params[:id]
    respond_to do |format|
      format.pdf { render :layout => 'default' }
    end
  end
  
  def getpdf
    @paper = 'Letter'
  end

  def scored_selection
    @cutoff = params[:cutoff] || nil
    @updated_apps = []
    @max_number_of_scores ||= 4

    @committee_mode = @offering.review_committee_submits_committee_score?
    @attribute_to_update = @committee_mode ? :application_final_decision_type_id : :application_review_decision_type_id

    if params[:details]
      @app = @offering.application_for_offerings.find(params[:id])
    end

    if params[:reset]
      @apps ||= @offering.application_for_offerings.reject{|a| a.reviewers.empty?}
      @apps.each{|a| a.update_attribute(@attribute_to_update, nil)}
      redirect_to :action => "scored_selection" and return
    end

    if params[:cutoff]
      if @committee_mode
        yes_option_id = @offering.application_final_decision_types.yes_option.id
        no_option_id = @offering.application_final_decision_types.no_option.id
        @apps ||= @offering.application_for_offerings.find(:all, 
                    :joins => :application_review_decision_type, 
                    :conditions => { "application_review_decision_types.yes_option" => true })
        @apps = @apps.sort_by{|x| (x.weighted_combined_score if x.weighted_combined_score > 0) || -1 }.reverse
        @score_attribute = "weighted_combined_score"
      else
        yes_option_id = @offering.application_review_decision_types.yes_option.id
        no_option_id = @offering.application_review_decision_types.no_option.id
        @apps ||= @offering.application_for_offerings.reject{|a| a.reviewers.empty?}.sort_by(&:average_score).reverse
        @score_attribute = "average_score"
      end
      for app in @apps
        if app.instance_eval(@score_attribute) > params[:cutoff].to_f
          app.update_attribute(@attribute_to_update, yes_option_id)
          @updated_apps << app
        else
          app.update_attribute(@attribute_to_update, no_option_id)
          @updated_apps << app
        end
      end
      respond_to do |format|
        format.html { return redirect_to :action => "scored_selection" }
        format.js { return }
      end
    end    
        
    if params[:decision_type_id]
      @app = @offering.application_for_offerings.find(params[:id])
      @app.update_attribute(@attribute_to_update, params[:decision_type_id])
    end
    
    if params[:review_committee_notes]
      @app = @offering.application_for_offerings.find(params[:id])
      @app.update_attribute(:review_committee_notes, params[:review_committee_notes])
    end
    
    if params[:final_committee_notes]
      @app = @offering.application_for_offerings.find(params[:id])
      @app.update_attribute(:final_committee_notes, params[:final_committee_notes])
    end
    
    if params[:requested_quarter] || params[:amount_requested] || params[:amount_awarded]
      @app = @offering.application_for_offerings.find(params[:id])
      
      for id,quarter in params[:requested_quarter]
        @app.awards.find(id).update_attribute(:requested_quarter_id, quarter)
      end
      
      for id,amount in params[:amount_requested]
        @app.awards.find(id).update_attribute(:amount_requested, amount)
      end
      
      for id,amount in params[:amount_awarded]
        @app.awards.find(id).update_attribute(:amount_awarded, amount)
      end
      
      @updated_apps << @app
    end
    
    respond_to do |format|
      format.html {
        if @committee_mode
          @apps ||= @offering.application_for_offerings.find(:all, 
                      :joins => :application_review_decision_type, 
                      :conditions => { "application_review_decision_types.yes_option" => true })
          @apps = @apps.sort_by{|x| (x.weighted_combined_score if x.weighted_combined_score > 0) || -1 }.reverse
          @max_number_of_scores = 4
          @cutoff = 1000 if @cutoff.nil?
        else
          @apps ||= @offering.application_for_offerings.reject{|a| a.reviewers.empty?}.sort_by{|a| a.average_score.to_s=="NaN" ? 0.0 : a.average_score}.reverse
          @max_number_of_scores ||= @apps.collect{|a| a.reviewers.size}.max
          @cutoff = 1000 if @cutoff.nil?
        end
      }
      format.js 
    end
  end

  # Returns the "mini_details" partial for the requested application.
  def mini_details
    @app = @offering.application_for_offerings.find(params[:id]) rescue nil
    if @app.nil?
      render :text => "Could not find an application matching that ID.", :status => 404
    else
      render :partial => "mini_details"
    end
  end

  def invited_guests
    session[:breadcrumbs].add "Invited Guests"
    @invited_guests = @confirmers.collect(&:guests).flatten.compact
    @not_mailed = @invited_guests.select{ |g| !g.invitation_mailed? }
    @mailed = @invited_guests.select{ |g| g.invitation_mailed? }.sort_by(&:invitation_mailed_at)
  end

  def postcard
    if params[:id]
      @guests = [ApplicationGuest.find(params[:id])]
    elsif params[:select]
      @guests = ApplicationGuest.find(params[:select].values.collect(&:keys))
    else
      flash[:error] = "You did not provide a guest to render a postcard for. Please try again."
      redirect_to :back and return
    end
    if params[:mark_as_mailed]
      @guests.each{ |g| g.update_attribute(:invitation_mailed_at, Time.now) }
      flash[:notice] = "Marked #{@guests.size} postcards as mailed."
    end
    
    respond_to do |format|
      format.html { redirect_to :back and return }
      format.pdf  { @paper = [22.86, 15.24] } # 2009: [ 24.13, 15.875]
    end
  end

  def mentor_postcard
    @people = {}
    for app in @apps.select{|a| a.in_status?(:confirmed)}
      for mentor in app.mentors
        person = mentor.person
        @people[person] = @people[person].nil? ? [app] : @people[person] << app unless person.nil?
      end
    end
    
    respond_to do |format|
      format.pdf { @paper = [ 22.86, 15.24] } # 2009: [ 24.13, 15.875]
    end
  end
  
  def guest
    @guest = ApplicationGuest.find params[:id]
    if request.post? && params[:guest]
      redirect_to :action => "invited_guests" if @guest.update_attributes(params[:guest])
    end
    session[:breadcrumbs].add "Invited Guests", :action => 'invited_guests'
    session[:breadcrumbs].add "Edit Guest Details"
  end

  def nominated_mentors
    session[:breadcrumbs].add "Nominated Mentors"
    @nominees = {}
    @offering.mentor_types.each{|t| @nominees[t.application_mentor_type] = {}}
    for nominator in @confirmers.reject{|c| c.nominated_mentor.nil? }
      mentor = nominator.nominated_mentor
      if mentor.person
        if @nominees[mentor.mentor_type][mentor.person].nil?
          @nominees[mentor.mentor_type][mentor.person] = [nominator]
        else
          @nominees[mentor.mentor_type][mentor.person] << nominator
        end
      end
    end
    @nominees.sort{|x,y| x.size <=> y.size }
    respond_to do |format|
      format.html # nominated_mentors.html.erb
      format.xls { render :action => 'nominated_mentors', :layout => 'basic' } # nominated_mentors.xls.erb
    end
  end
  
  def theme_responses
    session[:breadcrumbs].add(@offering.theme_response_title || "Theme Responses")
    @theme_responders = @confirmers.reject{|c| c.theme_response.blank? }
    @theme2_responders = @confirmers.reject{|c| c.theme_response2.blank? }
  end
  
  def proceedings_requests
    session[:breadcrumbs].add "Proceedings Requests"
    @proceedings_requests = @confirmers.collect(&:requests_printed_program).flatten.compact
  end
  
  def special_requests
    session[:breadcrumbs].add "Special Requests"
    @special_requests = @offering.application_for_offerings.find(:all, :conditions => "confirmed = 1 AND special_requests != ''")
    
    respond_to do |format|
      format.html
      format.xls  { render :action => 'special_requests', :layout => 'basic' }
    end
  end

  def proceedings
    @apps = @offering.sessions.for_type_in_group(1, 1).first.presenters
   render :layout => 'application', :preprocess => true
   
    # respond_to do |format|
    #   format.pdf { }
    # end
  end

  def composite_report
    if params[:include]
      parts = []
      params[:include].each do |part,value|
        parts << part.to_sym
      end
      @app = @offering.application_for_offerings.find params[:id]
      file = @app.composite_report.pdf(parts)
      unless file.is_a?(String)
        flash[:error] = "Sorry, but there was an error creating the file. (#{file.inspect})"
        redirect_to :action => "show", :id => params[:id] and return
      end
      send_file file, :disposition => 'attachment', :type => 'application/pdf' unless file.nil?
    else
      flash[:error] = "You have to identify which parts of the application to include."
      redirect_to :action => "show", :id => params[:id]
    end
  end

  def add_note
    @app = ApplicationForOffering.find params[:id]
    @note = @app.notes.create(params[:note])
    
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @app }
      format.js
    end
  end

  def department_name_cleanup
    @apps = @offering.applications_with_status("submitted")
    @depts = {}
    @depts_apps = {}
    for app in @apps
      for mentor in app.mentors
        dept = mentor.department
        @depts[dept] = @depts[dept].nil? ? [mentor] : @depts[dept] << mentor
        @depts_apps[dept] = @depts_apps[dept].nil? ? [mentor] : @depts_apps[dept] << mentor
      end
    end
    @depts = @depts.sort_by{|k,v| k.to_s}
    
    session[:breadcrumbs].add "Department Name Cleanup"
  end

  def update_mentor_departments
    @mentors = ApplicationMentor.find(params[:mentor_ids].split(","))
    return render :text => "You must supply a new department name" unless params[:new_department_name]
    return render :text => "You must supply a new department name" if params[:new_department_name].blank?
    @success = []
    for mentor in @mentors
      @success << mentor if mentor.person.update_attribute(:other_department, params[:new_department_name])
    end
    
    respond_to do |format|
      format.js
    end
  end

  # find application answers from offering project preference question_id from +option_column = 5+
  def amgen_project_preference
    session[:breadcrumbs].add @offering.name   
    admin_decision_statuses = %w(admin_decision_yes+ admin_decision_yes admin_decision_maybe+ admin_decision_maybe)
    
    app_answers = ApplicationAnswer.find_all_by_offering_question_id(@offering.questions.find_all_by_display_as_and_option_column('checkbox_options',5)).select{|a| a.answer != "false" && admin_decision_statuses.include?(a.application_for_offering.current_status_name)}   
        
    @preferences_dropdown = app_answers.collect(&:answer).flatten.compact.uniq.sort
    @lab_query = params[:lab_query].blank? ? @preferences_dropdown.first : params[:lab_query]
    @project_answers = app_answers.select{|a| a.answer == "#{@lab_query}"}          
  end    



  protected
  
  def fetch_offering
    if params[:offering]
      @offering = Offering.find params[:offering]
      session[:breadcrumbs].add "#{@offering.title}", admin_apply_path(@offering)
      require_user_unit @offering.unit
    end
  end
  
  def fetch_apps
    #@apps ||= ApplicationForOffering.find :all, :conditions => ['offering_id = ?', params[:offering]]
    @apps ||= @offering.application_for_offerings
  end
  
  # Retrieve all applications and group members for this offering who have confirmed.
  def fetch_confirmers
    @confirmers = @offering.application_for_offerings.find(:all, :conditions => { :confirmed => true })
    @confirmers << @offering.application_group_members.find(:all, :conditions => { :confirmed => true })
    @confirmers.flatten!
  end
  
  def find_selected_award_applications
    if params[:id]
      @apps = [ApplicationForOffering.find(params[:id])]
    elsif params[:select]
      @apps = ApplicationForOffering.find(params[:select].values.collect(&:keys))
    else
      @apps = @offering.application_for_offerings.awarded
    end
    sort_apps
  end
    
  def sort_apps
    @apps.sort! {|x,y| y <=> x }
  end
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Online Applications", admin_apply_home_url
  end

end
