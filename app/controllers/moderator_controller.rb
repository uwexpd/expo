class ModeratorController < ApplicationController
  before_filter :fetch_person, :fetch_offering, :apply_alternate_stylesheet, :fetch_moderator_committee_member, :fetch_offering_session, :fetch_apps
  before_filter :initialize_breadcrumbs
  helper 'admin/base'

  def index
    @apps = @apps.sort{|x,y| x.offering_session_order.nil? ? x.fullname <=> y.fullname : x.offering_session_order.to_i <=> y.offering_session_order.to_i }
    if request.post? && params[:offering_session]
      @offering_session.attributes = params[:offering_session]
      @offering_session.title_is_temporary = false if @offering_session.title_changed?
      @offering_session.require_new_title = true if params[:finalize]
      if @offering_session.save
        flash[:notice] = "Successfully saved session deatils."
        redirect_to :action => (params[:finalize] ? "finalize" : "index")
      else
        flash[:error] = "Could not save session details. Please correct the errors below."
      end
    end
  end

  def show
    @app = @apps.find(params[:id])
  end

  def update
    @app = @apps.find(params[:id])
    @app.require_moderator_comments = true
    if @app.update_attributes(params[:application_for_offering])
      flash[:notice] = "Successfully saved decision for #{@app.fullname}."
      redirect_to :action => "index"
    else
      flash[:error] = "Could not save your decision for #{@app.fullname}. Please correct the errors below."
      render :action => "show"
    end
  end

  def finalize
    @offering_session.update_attribute(:finalized, true)
    @offering_session.update_attribute(:finalized_date, Time.now)
    flash[:notice] = "Your session review has been submitted. Thank you!"
    redirect_to :action => "index"
  end

  def sort_session_apps
    params[:session_apps].each_with_index do |id, index|
      @offering_session.presenters.update_all(['offering_session_order=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
  
  def criteria
    render :action => 'criteria', :layout => 'popup'
  end

  protected
  
  def fetch_person
    @person = @current_user.person
  end
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    #Change moderator process, don't need moderator to make decisions in 2012
    @change_moderator_process = true if @offering.year_offered > 2011
  end

  def apply_alternate_stylesheet
    if @offering.alternate_stylesheet && File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', "#{@offering.alternate_stylesheet}.css"))
      @alternate_stylesheet = @offering.alternate_stylesheet
    end
  end

  def fetch_moderator_committee_member
    unless @offering.moderator_committee.nil?
      @moderator_committee_member = @offering.moderator_committee.members.find_by_person_id(@person)
      raise ExpoException.new("You are not listed as part of the moderator for that process.") and 
        return if @moderator_committee_member.nil?
    else
      raise ExpoException.new("That offering does not use moderators.") and return
    end
  end
  
  def fetch_offering_session
    @offering_session = @moderator_committee_member.offering_sessions.find_by_offering_id(@offering)
    raise ExpoException.new("You are not assigned as a moderator for any sessions.") and return if @offering_session.nil?
  end
  
  def fetch_apps
    @apps = @offering_session.presenters
  end

  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXP-Online", root_url, {:class => "home"}
    session[:breadcrumbs].add "Moderator Interface", :action => 'index'
    session[:breadcrumbs].add @offering.name, :action => 'index'
  end


end
