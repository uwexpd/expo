class Admin::Committees::MembersController < Admin::CommitteesController
  
  before_filter :fetch_committee, :add_committee_members_breadcrumbs #, :except => [:auto_complete_model_for_person_fullname]

  def auto_complete_model_for_person_fullname
    @result = Person.non_student.find_all{|p| p.fullname.downcase.include?(params[:person][:fullname].downcase)}[0..10]
    render :partial => "auto_complete", :object => @result, :locals => { :highlight_phrase => params[:person][:fullname] }
  end

  def index
    if params[:order]
      @members = @committee.members.find_and_sort(:all, :order => params[:order])
    else
      @members = @committee.members.find(:all, :include => :person, 
                                        :order => "status_cache='not_responded', status_cache, people.lastname, people.firstname")
    end
    @sorted_by_status = params[:order].blank? || params[:order].include?("status")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @members }
    end
  end

  def show
    @member = @committee.members.find(params[:id])
    @offerings = Offering.find(@member.application_reviewers.collect(&:offering_id))
    session[:breadcrumbs].add "#{@member.fullname rescue "Details"}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end
  
  def reviews
    @member = @committee.members.find(params[:id])
    @offerings = Offering.find_all_by_id(params[:offering_id] || @member.application_reviewers.collect(&:offering_id))
    session[:breadcrumbs].add "#{@member.fullname rescue "Details"}", :action => 'show'
    session[:breadcrumbs].add "Reviews"

    respond_to do |format|
      format.html # reviews.html.erb
      format.xml  { render :xml => @member }
    end
  end

  def new
    @member = @committee.members.build
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @member }
    end
  end

  def edit
    @member = @committee.members.find(params[:id])
    session[:breadcrumbs].add "#{@member.fullname rescue "Details"}", :action => 'show'    
    session[:breadcrumbs].add "Edit"
  end

  def create
    @member = @committee.members.new(params[:committee_member])

    respond_to do |format|
      if @member.save
        flash[:notice] = 'New committee member was successfully created.'
        format.html { redirect_to(admin_committee_member_path(@committee, @member)) }
        format.xml  { render :xml => @member, :status => :created, :location => @member }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @member = @committee.members.find(params[:id])

    respond_to do |format|
      params[:committee_member][:last_user_response_at] = Time.now if params[:update_user_response_at]
      if @member.update_attributes(params[:committee_member])
        flash[:notice] = 'Committee member was successfully updated.'
        format.html { redirect_to(admin_committee_member_path(@committee, @member)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @member = @committee.members.find(params[:id])
    @member.destroy

    respond_to do |format|
      format.html { redirect_to(admin_committee_members_url(@committee)) }
      format.xml  { head :ok }
    end
  end

  def change_status
    members = []
    if params[:select] && params[:new_status]
      for object_type, ids in params[:select]
        if object_type == 'CommitteeMember'
          for id, val in ids
            member = @committee.members.find(id)
            member.update_attribute(:last_user_response_at, Time.now) if params[:user_response]
            member.status = params[:new_status] if member
            members << member if member
          end
        end
      end
    end
    flash[:notice] = "Set status for #{members.size} member(s) to '#{params[:new_status]}'."
    redirect_to :action => "index"
  end

  protected
  
  def fetch_committee
    @committee = Committee.find(params[:committee_id])
  end

  def add_committee_members_breadcrumbs
    session[:breadcrumbs].add @committee.name, admin_committee_path(@committee)
    session[:breadcrumbs].add "Members", admin_committee_members_path(@committee)
  end
    
end
