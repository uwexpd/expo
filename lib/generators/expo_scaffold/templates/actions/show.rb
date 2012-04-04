  def show
    @<%= singular_name %> = <%= collection_class_name %>.find(params[:id])
    session[:breadcrumbs].add "#{@<%= singular_name %>.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end
