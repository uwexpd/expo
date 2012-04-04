class <%= name %>sController < <%= controller_superclass %>
<% if parent_name %>
  before_filter :fetch_<%= parent_name %><% end %>
  before_filter :add_<%= plural_name %>_breadcrumbs
  
  <%= controller_methods :actions %>

  protected
<% if parent_name %>
  def fetch_<%= parent_name %>
    @<%= parent_name %> = <%= parent_object %>.find params[:<%= parent_name %>_id]
    session[:breadcrumbs].add "#{@<%= parent_name %>.title}", <%= parent_path %>
  end
<% end %>
  def add_<%= plural_name %>_breadcrumbs
    session[:breadcrumbs].add "<%= plural_name.titleize %>", <%= items_path %>
  end

end
