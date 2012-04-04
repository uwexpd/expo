  def destroy
    @<%= singular_name %> = <%= collection_class_name %>.find(params[:id])
    @<%= singular_name %>.destroy
    flash[:notice] = "Successfully destroyed <%= singular_name.humanize.downcase %>."
    respond_to do |format|
      format.html { redirect_to <%= items_path('url') %> }
      format.xml  { head :ok }
      format.js
    end
  end
