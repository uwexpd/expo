class BreadcrumbTrail

  @breadcrumbs

  # Returns the Array of the contents of the breadcrumb trail, or a delimited string if a delimiter is provided
  def trail(delimiter = nil)
    return @breadcrumbs.collect{ |c| c[:title] }.join(delimiter) if delimiter
    @breadcrumbs
  end

  # Returns a string suitable for the window title: includes the first element ("EXP-Online") and the last 
  # crumb. If the last crumb is "New" or "Edit" then include the second-to-last crumb as well. Pass option
  # +skip_first => true+ if you don't want "EXP-Online" included.
  def title(delimiter = " > ", options = {})
    skippable_lasts = ["New", "Edit", "EXP-Online", "Admin Area", "Home"]
    first = options[:skip_first] ? nil : @breadcrumbs.first[:title]
    last = @breadcrumbs.last[:title]
    second_to_last = skippable_lasts.include?(last) ? (@breadcrumbs[@breadcrumbs.size-2][:title] rescue nil) : nil
    [first, second_to_last, last].compact.join(delimiter)
  end

  # Adds a crumb to the admin breadcrumb trail.
  def add(title, url = nil, options = nil)
    crumb = {}
    crumb[:title] = title
    crumb[:url]   = url
    crumb[:class] = options[:class] unless options.nil? || options[:class].nil?
    @breadcrumbs << crumb unless @breadcrumbs.include? crumb rescue nil
  end

  # Clears the breadcrumb in memory and starts a new one
  def start
    @breadcrumbs = Array.new
    @show_quarter_select_dropdown = false
  end

end