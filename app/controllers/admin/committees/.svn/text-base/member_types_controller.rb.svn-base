class Admin::Committees::MemberTypesController < Admin::CommitteesController

  before_filter :fetch_committee
  before_filter :add_member_types_breadcrumbs
  
  def index
    @member_types = @committee.member_types.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @member_types }
    end
  end
    
  def show
    @member_type = @committee.member_types.find(params[:id])
    session[:breadcrumbs].add "#{@member_type.name}"
    
	@new_select_value = { :value => @member_type.id, :title => @member_type.name }
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member_type }
    end
  end
  
  def new
    @member_type = @committee.member_types.new
    session[:breadcrumbs].add "New"

	@member_type.committee_id = params[:committee_id] if params[:committee_id]
	
    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @member_type }
    end
  end
  
  def create
    @member_type = @committee.member_types.new(params[:member_type])

    respond_to do |format|
      if @member_type.save
        flash[:notice] = "Successfully created member type."
        format.html { redirect_to admin_committee_member_type_path(@committee, @member_type) }
        format.xml  { render :xml => @member_type, :status => :created, 
                             :location => admin_committee_member_type_path(@committee, @member_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @member_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @member_type = @committee.member_types.find(params[:id])
    session[:breadcrumbs].add "#{@member_type.name}", admin_committee_member_type_path(@committee, @member_type)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @member_type = @committee.member_types.find(params[:id])

    respond_to do |format|
      if @member_type.update_attributes(params[:member_type])
        flash[:notice] = "Successfully updated member type."
        format.html { redirect_to admin_committee_member_type_path(@committee, @member_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @member_type = @committee.member_types.find(params[:id])
    @member_type.destroy
    flash[:notice] = "Successfully destroyed member type."
    respond_to do |format|
      format.html { redirect_to admin_committee_member_types_url(@committee) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_committee
    @committee = Committee.find params[:committee_id]
	session[:breadcrumbs].add "#{@committee.name}", [:admin, @committee]
  end

  def add_member_types_breadcrumbs
    session[:breadcrumbs].add "Member Types", admin_committee_member_types_path(@committee)
  end

end
