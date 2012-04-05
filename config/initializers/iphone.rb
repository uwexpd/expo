module ActionController
  class Base
    
    # Handles the case when iphone format is requested but no iphone-formatted template file exists.
    # This requires a two-pronged solution:
    # 
    # 1. Catch a MissingTemplate exception and try re-running the method asking for :html format
    #    instead of :iphone format.
    # 2. Store a variable called "force_layout_format" in the current Thread and set it to :html.
    #    This triggers ActionController::Layout#find_layout to fallback to the matching HTML layout
    #    as well. Without this, the page is displayed with the :html content but the :iphone layout
    #    (resulting in a blank white screen in most cases).
    # def default_template(action_name = self.action_name)
    #   begin
    #     self.view_paths.find_template(default_template_name(action_name), default_template_format)
    #   rescue ActionView::MissingTemplate => e
    #     if default_template_format == :iphone
    #       Thread.current['force_layout_format'] = :html
    #       self.view_paths.find_template(default_template_name(action_name), :html)
    #     else
    #       raise
    #     end
    #   end
    # end

  end
end


module ActionController
  module Layout
    
    # def find_layout(layout, format, html_fallback=false) #:nodoc:
    #   format = Thread.current['force_layout_format'] || format
    #   view_paths.find_template(layout.to_s =~ /layouts\// ? layout : "layouts/#{layout}", format, html_fallback)
    # rescue ActionView::MissingTemplate
    #   raise if Mime::Type.lookup_by_extension(format.to_s).html?
    # end
    
  end
end