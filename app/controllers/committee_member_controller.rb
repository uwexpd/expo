class CommitteeMemberController < ApplicationController
  layout 'admin'
  helper_method :get_breadcrumbs
  before_filter :initialize_breadcrumbs
  before_filter :map_to_committee_member
  before_filter :fetch_person
  before_filter :fetch_committee_members, :except => [:map]
  before_filter :assign_committee_member, :except => [:map, :which]

  def get_breadcrumbs
    breadcrumbs
  end
  
  def which
    if params[:committee_member]
      session[:committee_member_id] = params[:committee_member][:id]
      redirect_to :action => "index"
    end
  end
  
  def index
  end
  
  def complete
  end
  
  def availability
    session[:breadcrumbs].add "Availability"
    if params[:committee_member]
      params[:committee_member][:last_user_response_at] = Time.now
      if @committee_member.update_attributes(params[:committee_member])
        flash[:notice] = "Availability saved successfully."
        redirect_to :action => "complete", :inactive => "true" and return unless @committee_member.currently_active?
        chose_quarters = @committee_member.committee_member_quarters.upcoming(2).collect(&:active?).include?(true)
        redirect_to :action => "complete", :inactive => "true" and return if !chose_quarters
        redirect_to :action => 'specialty'
      else
        flash[:error] = "Could not save your changes."
      end
    end
  end

  def specialty
    session[:breadcrumbs].add "Specialty"
    if params[:committee_member]
      if @committee_member.update_attributes(params[:committee_member])
        flash[:notice] = "Specialty saved successfully."
        redirect_to :action => 'meetings'
      else
        flash[:error] = "Could not save your changes."
      end
    end
  end

  def meetings
    session[:breadcrumbs].add "Meetings"
    if @committee_member.committee_member_meetings.future.empty?
      unless @committee_member.committee.interview_offering_id.blank?
         Offering.find(@committee_member.committee.interview_offering_id).offering_interviewers.create(:person_id => @committee_member.person_id)
         redirect_to interviewer_path(:offering => @committee_member.committee.interview_offering_id , 
                                      :action => 'availability',
                                      :committee => @committee_member.committee, 
					                            :no_meeting => @committee_member.committee_member_meetings.future.empty?) and return
      end      
      redirect_to :action => "complete"
    end
    if params[:committee_member]
      if @committee_member.update_attributes(params[:committee_member])
        flash[:notice] = "All information saved."
        redirect_to :action => 'complete'
      else
        flash[:error] = "Could not save your changes."
      end
    end
  end

  def profile
    session[:breadcrumbs].add "Edit My Profile"
    if params[:person]
      @person.attributes = params[:person]
      @person.require_validations = true
      if @person.save
        flash[:notice] = "Successfully saved contact information."
        redirect_to params[:to] || { :action => 'index' }
      end
    end
  end

  # We offer an alternative map method here because Pubcookie authentication seems to have a problem with the query parameter
  # method used in map_to_committee_member below (e.g., +?map=123&t=sdkfjsdf+).
  def map
    committee_partner_id = params[:committee_member_id]
    token = params[:token]
    if @committee_member = Token.find_object(committee_partner_id, token, false)
      @committee_member.update_attribute(:person_id, @current_user.person_id)
      @committee_member.token.generate
      render :action => 'profile'
    else
      redirect_to params[:to] || { :action => "index" }
    end
  end
  
  
  protected

  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXP-Online", "/expo/committee_member", {:class => "home"}
    session[:breadcrumbs].add "Committee Member", "/expo/committee_member"
  end

  # Maps this person to a CommitteeMember record if a valid token is sent with the URL. Note that EXPo always uses the rule that
  # "the person knows him or herself the best," so when mapping a person to a CommitteeMember, we completely disconnect from the
  # Person that was originally connected to this CommitteeMember. So if a staff person adds a new CommitteeMember to this Committee
  # (along with a new person) and says that the person's name is "Bob Smith" and then the user logs in using one of these mapped URLs
  # and the user's Person record says that his name is "Michael Jordan" we're going to trust the user and the CommitteeMember would
  # now be connected to the Michael Jordan Person record. This means that on the admin side, that Bob Smith CommitteeMember would suddenly
  # change to Michael Jordan without warning. This could potentially cause problems at some point, so this method should be revisited.
  def map_to_committee_member
    session[:committee_member_id] = params[:committee_member_id] if params[:committee_member_id]
    if params[:committee_member_id] && params[:token]
      committee_member_id = params[:committee_member_id]
      token = params[:token]
      if @committee_member = Token.find_object(committee_member_id, token, false)
          @committee_member.update_attribute(:person_id, @current_user.person_id)
          @committee_member.token.generate
          redirect_to :action => 'profile', :to => url_for(params[:to] || {:action => 'index'})
      else
        # flash[:error] = "That login link is no longer valid. Please contact your organization service-learning supervisor."
      end
    end
  end
  
  def fetch_person
    @person = @current_user.person
  end
  
  def fetch_committee_members
    raise ExpoException.new("You aren't a member of any committees.", "If you were sent a link to login to this site, try clicking on the link again.") if @person.committees.empty?
    @committee_members = @person.committee_members
    @committees = @person.committees
  end
  
  def assign_committee_member
    redirect_to :action => "which" and return if @committees.size > 1 && !session[:committee_member_id]
    @committee_member = @committees.size == 1 ? @committee_members.first : @committee_members.find(session[:committee_member_id])
    @committee = @committee_member.committee
  end
  
end
