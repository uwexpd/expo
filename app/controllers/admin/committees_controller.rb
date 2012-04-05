class Admin::CommitteesController < Admin::BaseController
  
  before_filter :add_committee_breadcrumbs

  def index
    @committees = Committee.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @committees }
    end
  end

  def show
    @committee = Committee.find(params[:id])
    session[:breadcrumbs].add @committee.name

    respond_to do |format|
      format.html # { redirect_to admin_committee_members_url(@committee) }
      format.xml  { render :xml => @committee }
    end
  end

  def new
    @committee = Committee.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @committee }
    end
  end

  def edit
    @committee = Committee.find(params[:id])
    session[:breadcrumbs].add @committee.name, admin_committee_url(@committee)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @committee = Committee.new(params[:committee])

    respond_to do |format|
      if @committee.save
        flash[:notice] = 'Committee was successfully created.'
        format.html { redirect_to(admin_committee_url(@committee)) }
        format.xml  { render :xml => @committee, :status => :created, :location => @committee }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @committee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @committee = Committee.find(params[:id])

    respond_to do |format|
      if @committee.update_attributes(params[:committee])
        flash[:notice] = 'Committee was successfully updated.'
        format.html { redirect_to(admin_committee_url(@committee)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @committee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @committee = Committee.find(params[:id])
    @committee.destroy

    respond_to do |format|
      format.html { redirect_to(admin_committees_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def add_committee_breadcrumbs
    session[:breadcrumbs].add "Committees", admin_committees_url
  end
  
end