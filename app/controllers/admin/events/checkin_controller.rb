class Admin::Events::CheckinController < Admin::EventsController
  include ActionView::Helpers::TextHelper
  before_filter :fetch_event
  before_filter :pipeline_orientation_event, :only => [:checkin, :find_student, :mass_checkin]

  before_filter :adjust_format_for_iphone, :except => [:checkin]

  def auto_complete
    # @result = {}
    
    @result = []
    query = params[:invitee][:fullname].downcase
    
    return render(:partial => 'empty_result') if query.blank?
    
    unless query.blank?
      # applicants = @event.attendees.find(:all, 
      #                                   :select => select_query, 
      #                                   :joins => "INNER JOIN application_for_offerings 
      #                                               ON application_for_offerings.id = event_invitees.invitable_id 
      #                                             INNER JOIN people 
      #                                               ON people.id = application_for_offerings.person_id", 
      #                                   :conditions => "invitable_type = 'ApplicationForOffering'")
      # group_members = @event.attendees.find(:all, 
      #                                   :select => select_query, 
      #                                   :joins => "INNER JOIN application_group_members 
      #                                               ON application_group_members.id = event_invitees.invitable_id 
      #                                             INNER JOIN people 
      #                                               ON people.id = application_group_members.person_id", 
      #                                   :conditions => "invitable_type = 'ApplicationGroupMember'")
      # people = @event.attendees.find(:all,
      #                                   :select => select_query,
      #                                   :joins => "INNER JOIN people 
      #                                               ON people.id = event_invitees.invitable_id",
      #                                   :conditions => "invitable_type = 'Person' OR invitable_type = 'Student'")
      # all_else = @event.attendees.find(:all, 
      #                                   :conditions => "invitable_type != 'ApplicationForOffering' 
      #                                                   AND invitable_type != 'ApplicationGroupMember'
      #                                                   AND invitable_type != 'Person'
      #                                                   AND invitable_type != 'Student'")
      # for attendee in applicants + group_members + people + all_else
      #   fullname = attendee.lastname + ", " + attendee.firstname rescue nil
      #   count = fullname.to_s.downcase.scan(query).size
      #   @result[attendee] = count unless count.zero? or count.nil?
      # end
      # @result = @result.sort_by{ |k,v| v }.reverse[0..8]
      
      name_conditions = []; group_name_conditions = []
      # if query.include?(",")
        query.gsub!(", ", ",") # remove the space from the name so we're consistent
        query = query.downcase.gsub(/\\/, '\&\&').gsub(/'/, "''")
        name_conditions << "LOWER(CONCAT(people.lastname,',',people.firstname)) LIKE '#{query}%'"
        group_name_conditions << "LOWER(CONCAT(application_group_members.lastname,',',application_group_members.firstname)) LIKE '#{query}%'"
      # else
      #   query.split.each do |name_part|
      #     name_part = name_part.downcase.gsub(/\\/, '\&\&').gsub(/'/, "''")
      #     name_conditions << "LOWER(people.firstname) LIKE '%#{name_part}%'"
      #     name_conditions << "LOWER(people.lastname) LIKE '%#{name_part}%'"
      #     group_name_conditions << "LOWER(application_group_members.firstname) LIKE '%#{name_part}%'"
      #     group_name_conditions << "LOWER(application_group_members.lastname) LIKE '%#{name_part}%'"
      #   end
      # end

      select_query = "event_invitees.*, 
                      people.firstname AS person_firstname, 
                      people.lastname AS person_lastname,
                      people.nickname AS person_nickname"
                      
      group_members_select_query = "#{select_query},
                      application_group_members.firstname AS group_member_firstname,
                      application_group_members.lastname AS group_member_lastname"

      applicants = @event.attendees.find :all, 
              :select => select_query,
              :joins => "INNER JOIN application_for_offerings 
                          ON application_for_offerings.id = event_invitees.invitable_id 
                        INNER JOIN people 
                          ON people.id = application_for_offerings.person_id", 
              :include => [:person],
              :conditions => "(#{name_conditions.join(" OR ")})",
              :order => "people.lastname, people.firstname"

      group_members = @event.attendees.find :all, 
              :select => group_members_select_query,
              :joins => "INNER JOIN application_group_members 
                          ON application_group_members.id = event_invitees.invitable_id 
                        INNER JOIN people 
                          ON people.id = application_group_members.person_id", 
              :include => [:person, :invitable],
              :conditions => "(#{(name_conditions + group_name_conditions).join(" OR ")})",
              :order => "people.lastname, application_group_members.lastname, people.firstname, application_group_members.firstname"
      
      people = @event.attendees.find(:all,
              :joins => "INNER JOIN people 
                          ON people.id = event_invitees.invitable_id",
              :include => [:person],
              :conditions => "invitable_type = 'Person' OR invitable_type = 'Student' AND (#{name_conditions.join(" OR ")})")

      # all_else = @event.attendees.find(:all, 
      #         :conditions => "invitable_type != 'ApplicationForOffering' 
      #                         AND invitable_type != 'ApplicationGroupMember'
      #                         AND invitable_type != 'Person'
      #                         AND invitable_type != 'Student'")

      @result = (applicants + group_members + people).flatten.compact.uniq[0..30]
    end
    render :partial => "auto_complete", :object => @result, :locals => { :highlight_phrase => params[:invitee][:fullname] }
  end

  def index
    session[:breadcrumbs].add "#{@event.title}", @event
    session[:breadcrumbs].add "Check-in"
    
    respond_to do |format|
      format.html
      format.iphone
    end
    
  end

  def checkin
    @invitee = @event.invitees.find params[:id] rescue nil
    if @invitee.nil?
      @error_message = "Could not find record."
    else
      if @invitee.checkin!
        # if this is a pipeline orientaiton update the students pipeline_orientation field
        update_student_pipeline_orientation(@invitee.person,@invitee.event_time) if (@pipeline_orientation && !@invitee.person.nil?)
        
        # If this is a mobile checkin, mark the invitee record as such
        @invitee.update_attribute(:mobile_checkin, true) if params[:mobile]
        
        flash[:notice] = "#{@invitee.invitable.firstname_first} was successfully checked in."
      else
        @error_message = "Could not complete your request. (Invitee ID: #{params[:id].to_s})"
        flash[:error] = @error_message
      end
    end
    respond_to do |format|
      format.html   { redirect_to :action => "index" }
      format.js     
      format.iphone
    end
  end

  def find_student
    @student = Student.find_by_student_no(params[:student_no])
    @event_time = @event.times.find(params[:event_time_id]) || @event.times.first
    @invitee = @event.find_attendee(@student) || @event_time.invite!(@student)
    
    # if this is a pipeline orientaiton update the students pipeline_orientation field
    update_student_pipeline_orientation(@student,@event_time) if (@pipeline_orientation && !@student.nil?)
    
    respond_to do |format|
      if @invitee && @invitee.checkin!
        format.js
      else
        format.js { render :update do |page| page.replace_html 'find_student_error', 'Error checking in student. Please check if student number is correct.' end }
      end
    end
    
  end

  def status
    if params[:last_updated_at]
      @invitees = @event.attended.find :all, 
        :include => [:person, :invitable], 
        :conditions => ["checkin_time > ?", params[:last_updated_at]],
        :order => "checkin_time ASC", 
        :limit => 50
    else
      @invitees = @event.attended.paginate :all, 
        :include => [:person, :invitable], 
        :order => "checkin_time DESC", 
        :page => (params[:page] || 1),
        :per_page => 15
    end

    session[:breadcrumbs].add "#{@event.title}", @event
    session[:breadcrumbs].add "Check-in", event_checkin_index_path(@event)    
    session[:breadcrumbs].add "Status"
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def mass
    session[:breadcrumbs].add "#{@event.title}", @event
    session[:breadcrumbs].add "Check-in", event_checkin_index_path(@event)    
    session[:breadcrumbs].add "Mass Check-in"
  end
  
  def mass_checkin
    @event_time = @event.times.find(params[:event_time_id]) || @event.times.first
    if params[:students].blank?
      flash[:error] = "You must provide a list of student numbers or NetID's."
      render :action => "mass" and return
    else
      @students = []
      @success_count = 0
      params[:students].split.each do |n|
        n = n.strip
        student_to_add = n.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) ? Student.find_by_student_no("#{n}") : Student.find_by_uw_netid("#{n}")
        if student_to_add.nil?
          @students << n unless n.blank?
        else
          if @event_time.invite!(student_to_add, :checkin_time => Time.now)
            @success_count += 1 
            
            # if this is a pipeline orientaiton update the students pipeline_orientation field
            update_student_pipeline_orientation(student_to_add,@event_time) if @pipeline_orientation
          end
        end
      end
      flash[:notice] = "Successfully checked in #{pluralize(@success_count, "student")}." unless @success_count.zero?
      if !@students.empty?
        flash[:error] = "Could not check in #{pluralize(@students.size, "student")}. See below."
        render :action => "mass" and return
      else
        redirect_to :action => "status" and return
      end
    end
  end
  
  def show
    @invitee = @event.invitees.find params[:id]
    
    respond_to do |format|
      format.iphone
    end
  end
  
  def update_note
    @invitee = @event.invitees.find params[:id]
    @invitee.update_attribute(:checkin_notes, params[:attendee][:checkin_notes])
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
    end
  end
  
  def manual
    @event_time = @event.times.find(params[:event_time_id] || @event.times.first)
    @extra_pages = params[:extra_pages].to_i
    
    respond_to do |format|
      format.html
      format.pdf
    end
  end
  
  private
  
  def fetch_event
    @event = Event.find(params[:event_id])
  end
  
  # check to see if this event is a pipeline orientation so we can update the person's pipeline_orientation field
  # the field is updated in :checkin, :find_student, :mass_checkin
  def pipeline_orientation_event
    @pipeline_orientation = (@event.event_type.try(:title) == "Orientation" && @event.unit.try(:abbreviation) == "pipeline")
  end
  
  # updates the students pipeline_orientation field
  def update_student_pipeline_orientation(student,event_time)
    if student.pipeline_orientation.nil? || (student.pipeline_orientation < event_time.start_time)
      student.pipeline_orientation = event_time.start_time
      student.save
    end
  end
  
end