  def edit
    @<%= singular_name %> = <%= collection_class_name %>.find(params[:id])
    session[:breadcrumbs].add "#{@<%= singular_name %>.title}", <%= show_path(true) %>
    session[:breadcrumbs].add "Edit"
  end
