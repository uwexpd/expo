class Admin::Apply::GroupMembersController < Admin::ApplyController
  before_filter :fetch_app
  before_filter :add_group_member_breadcrumbs
  skip_before_filter :fetch_apps
  skip_before_filter :fetch_confirmers

  def index
    @group_members = @app.group_members.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @group_members }
    end
  end

  def show
    @group_member = @app.group_members.find(params[:id])
    session[:breadcrumbs].add "#{@group_member.lastname_first}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group_member }
    end
  end

  def new
    @group_member = @app.group_members.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group_member }
    end
  end

  def edit
    @group_member = @app.group_members.find(params[:id])
    session[:breadcrumbs].add "#{@group_member.lastname_first}", :action => 'show', :id => @group_member
    session[:breadcrumbs].add "Edit"
  end

  def create
    @group_member = @app.group_members.new(params[:group_member])

    respond_to do |format|
      if @group_member.save
        flash[:notice] = "@app.group_members was successfully created."
        format.html { redirect_to :action => 'show', :id => @group_member }
        format.xml  { render :xml => @group_member, :status => :created, :location => { :action => 'index' } }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @group_member = @app.group_members.find(params[:id])

    respond_to do |format|
      if @group_member.update_attributes(params[:group_member])
        flash[:notice] = "#{@group_member.lastname_first} was successfully updated."
        format.html { redirect_to :action => 'show', :id => @group_member }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group_member = @app.group_members.find(params[:id])
    @group_member.destroy
    flash[:notice] = "Deleted #{@group_member.firstname_first}"

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end
  end
  
  protected

  def fetch_app
    @app = @offering.application_for_offerings.find params[:application_id]
    session[:breadcrumbs].add "#{@app.lastname_first}", admin_app_url(@offering, @app, :anchor => 'group_members')
  end

  def add_group_member_breadcrumbs
    session[:breadcrumbs].add "Group Members", admin_apply_group_members_url(@offering, @app)
  end
  
end
