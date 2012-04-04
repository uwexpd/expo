  def update
    @<%= singular_name %> = <%= collection_class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = "Successfully updated <%= singular_name.humanize.downcase %>."
        format.html { redirect_to <%= item_path %> }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end
