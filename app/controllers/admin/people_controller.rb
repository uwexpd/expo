class Admin::PeopleController < Admin::BaseController
  before_filter :add_to_breadcrumbs

  def index
    session[:breadcrumbs].add "All People in EXPo"
    @people = Person.paginate :order => 'lastname ASC, firstname ASC', :conditions => { :type => nil }, :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end
  
  def show
    @person = params[:search].blank? ? Person.find_by_id(params[:id]) : Person.find_by_anything(params[:search])
    if @person.nil? || (@person.is_a?(Array) && @person.empty?)
      flash[:error] = "Sorry, but we couldn't find a person record that matched your criteria."
      redirect_to :action => "index" and return
    end
    
    @quarter = Quarter.current_quarter
    
    session[:breadcrumbs].add @person.fullname

    if params['tab']
      render :partial => "admin/people/tabs/#{params[:tab]}", :locals => { :admin_view => true } and return
    end
  end
  
  def edit
    save_return_to
    @person = Person.find params[:id]
    session[:breadcrumbs].add "#{@person.fullname}"
  end
  
  def create
    @person = Person.new(params[:person])
    @person.require_validations = true
    if @person.save
      flash[:notice] = "Successfully created Person #{@person.id}"
      redirect_to :action => "show"
    else
      render :action => "new"
    end
      
  end
  
  def update
    @person = Person.find params[:id]
    if @person.update_attributes(params[:person])
      flash[:notice] = "Successfully saved person record."
      render :action => "show"
    else
      render :action => "edit"
    end
  end
  
  def new
    @person = Person.new
    session[:breadcrumbs].add "New Person"
  end
  
  def note
    @person = Person.find(params[:id])
    @note = @person.notes.create(params[:note])
    
    respond_to do |format|
      format.html { redirect_to admin_person_path(@person) }
      format.js
    end    
  end

  def search
    session[:breadcrumbs].add "Search"
    @people = Person.find(:all, :conditions => ['email = ?', params[:search][:email]]) unless params[:search][:email].blank?
    
    if @people.empty?
      flash[:error] = "Can not find the person with your search input."
      redirect_to :action => "index" and return
    end
    @people = @people.paginate(:page => params[:page], :per_page => 25)
    render :action => "index"    
  end

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "People", :action => 'index'
  end
  
end
