# StylesheetInclude
module StylesheetInclude

  def stylesheet_include_tag(*sources)
    if sources.include?(:controller)
      sources.delete(:controller)
      sources.push(controller_stylesheet_source) if stylesheet_exists(controller_stylesheet_source)
    end

    if sources.include?(:action)
      sources.delete(:action)
      sources.push(action_stylesheet_source) if stylesheet_exists(action_stylesheet_source)
    end

    if sources.include?(:plugins)
      sources.delete(:plugins)
      sources.push(valid_plugin_stylesheets) if stylesheet_exists(plugin_stylesheet_source)
    end

    if sources.include?(:defaults)
      sources.delete(:defaults)
      sources.unshift('application')
      sources.push(controller_stylesheet_source) if stylesheet_exists(controller_stylesheet_source)
      sources.push(action_stylesheet_source) if stylesheet_exists(action_stylesheet_source)
      sources.push(valid_plugin_stylesheets) if stylesheet_exists(plugin_stylesheet_source)
    end
    sources.flatten.collect { |source|
#      path = "/stylesheets/#{source}.css"
      path = stylesheet_path(source)
      tag('link', { 'type' => 'text/css', 'rel' => 'stylesheet', 'href' => path})
    }.join("\n")

  end

  protected
  def controller_stylesheet_source
    params[:controller]
  end

  def action_stylesheet_source
    [ params[:controller], params[:action] ].join("_")
  end

  def stylesheet_physical_path(source)
    "#{RAILS_ROOT}/public/stylesheets/#{source}.css"
  end

  def plugin_stylesheet_source
    d = Dir.entries "#{RAILS_ROOT}/vendor/plugins"
    d.delete "."
    d.delete ".."
    d
  end

  def stylesheet_exists(source)
    source = [source] unless source.kind_of? Array
    flag=false
    source.each do |s|
      flag |= File.exists?(stylesheet_physical_path(s))
    end
    return flag
  end

  def valid_plugin_stylesheets()
    sheets=[]
    sources = plugin_stylesheet_source
    sources.each do |source|
      sheets << source if File.exists?(stylesheet_physical_path(source))
    end
    return sheets
  end

end
