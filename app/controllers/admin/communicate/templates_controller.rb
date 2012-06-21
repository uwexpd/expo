class Admin::Communicate::TemplatesController < Admin::BaseController
  before_filter :add_to_breadcrumbs

  def index
    @non_email_templates = TextTemplate.non_email.sort
    @email_templates = EmailTemplate.all.sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @text_templates }
    end
  end

  def show
    @text_template = TextTemplate.find(params[:id])
    session[:breadcrumbs].add "#{@text_template.name.titleize}"

  	@new_select_value = { :value => @text_template.id, :title => @text_template.title }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @text_template }
    end
  end

  def new
    @text_template = params[:type] == 'EmailTemplate' ? EmailTemplate.new : TextTemplate.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] } # new.html.erb
      format.xml  { render :xml => @text_template }
    end
  end

  def edit
    @text_template = TextTemplate.find(params[:id])
    session[:breadcrumbs].add "#{@text_template.name.titleize}", admin_communicate_template_path(@text_template)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @text_template = params[:type] == 'EmailTemplate' ? EmailTemplate.new(params[:text_template]) : TextTemplate.new(params[:text_template])

    respond_to do |format|
      if @text_template.save
        flash[:notice] = "#{@text_template.class} successfully created."
        format.html { redirect_to(admin_communicate_template_path(@text_template)) }
        format.xml  { render :xml => @text_template, :status => :created, :location => @text_template }
      else
        format.html { render :action => "new", :layout => ("popup" if params[:popup_layout]) }
        format.xml  { render :xml => @text_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @text_template = TextTemplate.find(params[:id])
    session[:breadcrumbs].add "Edit"

    respond_to do |format|
      if @text_template.update_attributes(params[:text_template])
        flash[:notice] = 'TextTemplate was successfully updated.'
        format.html { redirect_to(admin_communicate_template_path(@text_template)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @text_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @text_template = TextTemplate.find(params[:id])
    @text_template.destroy
    flash[:notice] = "Template \"#{@text_template.title}\" was sucessfully deleted."

    respond_to do |format|
      format.html { redirect_to(admin_communicate_templates_path) }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete    
    @email_templates = EmailTemplate.find(:all,  :conditions => "name LIKE '%#{params[:q]}%'")
    
    respond_to do |format|
      format.js
    end
  end  

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Templates", admin_communicate_templates_url
  end
  
end
