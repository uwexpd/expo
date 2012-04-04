  def new
    @<%= singular_name %> = <%= collection_class_name %>.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end
