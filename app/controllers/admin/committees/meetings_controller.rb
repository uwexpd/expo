class Admin::Committees::MeetingsController < Admin::CommitteesController
  
  before_filter :fetch_committee
  before_filter :add_committee_meetings_breadcrumbs

  def index
    @meetings = @committee.meetings

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meetings }
    end
  end

  def show
    @meeting = @committee.meetings.find(params[:id])
    session[:breadcrumbs].add "#{@meeting.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meeting }
    end
  end

  def new
    @meeting = @committee.meetings.build
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meeting }
    end
  end

  def edit
    @meeting = @committee.meetings.find(params[:id])
    session[:breadcrumbs].add "#{@meeting.title}", admin_committee_meeting_path(@committee, @meeting)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @meeting = @committee.meetings.build(params[:meeting])

    respond_to do |format|
      if @meeting.save
        flash[:notice] = 'Committee meeting was successfully created.'
        format.html { redirect_to(admin_committee_meeting_path(@committee, @meeting)) }
        format.xml  { render :xml => @meeting, :status => :created, :location => @meeting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meeting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @meeting = @committee.meetings.find(params[:id])

    respond_to do |format|
      if @meeting.update_attributes(params[:committee_meeting])
        flash[:notice] = 'Committee meeting was successfully updated.'
        format.html { redirect_to(admin_committee_meeting_path(@committee, @meeting)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meeting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @meeting = @committee.meetings.find(params[:id])
    @meeting.destroy

    respond_to do |format|
      format.html { redirect_to(admin_committee_meetings_url(@committee)) }
      format.xml  { head :ok }
    end
  end


  protected
  
  def fetch_committee
    @committee = Committee.find(params[:committee_id])
    session[:breadcrumbs].add "#{@committee.name}", [:admin, @committee]
  end

  def add_committee_meetings_breadcrumbs
    session[:breadcrumbs].add "Meetings", admin_committee_meetings_path(@committee)
  end
    
end
