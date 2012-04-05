# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  def required
    content_tag(:em, "*", :class => 'required')
  end

  def required_message
    content_tag(:p, "Fields marked #{required} are required.", :class => 'smaller light')
  end

  def title(page_title = "EXP-Online", subtitle = nil)
    content_for(:page_title) { page_title }

    content_for(:unit_name) { 
      subtitle.nil? ? "" : subtitle 
    }

    content_for(:title) { 
      subtitle.nil? ? page_title : page_title + " > " + subtitle
    }
  end
  
  def subtitle(content)
    content_for(:after_page_title) { 
      content_tag('span', content, :class => 'after_page_title') unless content.nil?
    }
  end

  # creates a sidebar element 
  #### relative sibebar:
  ## <% sidebar :with_selected %>
  #### absolute sibebar:
  ## <% sidebar "full/sidebar/path" %>
  #### side bar with locals:
  ## <% sidebar :with_selected, {:locals => {:local_name => local_value}} %>
  def sidebar(*blocks)
    options = blocks.reject{|b| !b.is_a? Hash}.first || {}
    
    blocks.reject!{|b| b.is_a? Hash}
    blocks.each do |b|
      content_for :sidebar do
        if b.is_a? Symbol
          render :partial => "admin/sideblock", :locals => { :sideblock_to_render => b, :options => options }
        else
          render :partial => "admin/sideblock_full_path", :locals => { :sideblock_to_render => b, :options => options }
        end
      end
    end
  end  

  
  def make_main_content_blocked
    content_for :main_content_class do
      "blocked"
    end
  end
  
  def make_main_content_full_width
    content_for :main_class do
      "full_width"
    end
  end


  def mark_as_confidential(note = nil)
    note ||= "CONFIDENTIAL"
    content_for(:confidentiality_note) do
      "&bull; #{note} &bull;"
    end
  end
  
  def address_block(obj, delimiter = "<br>")
    if obj.is_a? Person
      address_block_for_person(obj, delimiter)
    elsif obj.is_a? Location
      address_block_for_location(obj, delimiter)
    else
      nil
    end
  end
  
  # Creates a printable address block from a person record.
  def address_block_for_person(person, delimiter = "<br>")
    a = "#{person.address1}"
    a << "#{delimiter}#{person.address2}" unless person.address2.blank?
    a << "#{delimiter}#{person.address3}" unless person.address3.blank?
    a << "#{delimiter}" unless person.city.blank? || person.state.blank? || person.zip.blank?
    a << "#{person.city}" unless person.city.blank?
    a << ", " unless person.city.blank? && person.state.blank?
    a << "#{person.state} "
    a << "#{person.zip}"
  end
  
  # Creates a printable address block from a location record
  def address_block_for_location(location, delimiter = "<br>")
    a = "#{location.address_line_1}"
    a << "#{delimiter}#{location.address_line_2}" unless location.address_line_2.blank?
    a << "#{delimiter}" unless location.address_city.blank? || location.address_state.blank? || location.address_zip.blank?
    a << "#{location.address_city}" unless location.address_city.blank?
    a << ", " unless location.address_city.blank? && location.address_state.blank?
    a << "#{location.address_state} "
    a << "#{location.address_zip}"    
  end
  
  # Tries to produce a human-readable phone number. Strips all non-digits and then feeds to number_to_phone
  def phone_number(number)
    number.nil? ? "" : number_to_phone(number.to_s.strip[0..9], :area_code => true, :extension => number.to_s.strip[10..20])
  end
  
  # Truncates a string to the first line-break or number of characters, whichever comes first.
  def truncate_to_whitespace(text, length = 100, truncate_string = "...")
    if text.nil? then return end
    text[0..text.index($/)] rescue text
  end
  
  # Truncates a string using truncate_to_whitespace but also includes a link to view the rest, which includes a Javascript link to expand.
  def truncate_to_whitespace_with_link(text, length = 100, truncate_string = "(continued)")
    if text.nil? then return end
    div_id = "truncate_" + rand(100000000000).to_s
    if text.index($/) # yes, we found whitespace - truncate to that
      before_text = text[0..text.index($/)]
      after_text = text[text.index($/)..text.length]
    else
      return text
    end
    str = before_text
    str << link_to_function(truncate_string, "Effect.toggle('#{div_id}', 'blind', {duration: 0.25})")
    str << "<div id='#{div_id}' style='display:none'>"
    str << simple_format(after_text)
    str << link_to_function("(show less)", "Effect.toggle('#{div_id}', 'blind', {duration: 0.25})")
    str << "</div>"
  end
  
  # Creates a tab in a TabView for ajax-based tabs
  def link_to_tab(title, id, url, update, options = {})
    section = id
    id = "tabview_#{update.hash}_#{id}"
    str = "<li id='#{id}' class='#{options[:class]}'>"
  	str << link_to_remote(title, 
  	        :url => url, 
  	        :update => update, 
  	        :loading => "$$('.tabview #tabs li.current').invoke('removeClassName','current'); $('#{id}').addClassName('current'); window.location.replace('##{section}');", 
  	        :indicator => true,
  	        :method => :get,
  	        :id => options[:link_id])
  	str << "</li>"
    str
  end
	
	# Autoloads a tab based on the hash in the URL string
	def autoload_tab(update, url, default)
    src = "
      if (window.location.hash) {
        tab = window.location.hash.split('#')[1];
      } else {
        tab = '#{params[:tab] || default}';
      }
      new Ajax.Updater('tabview_content', 
          '#{url}' + tab,{asynchronous:true, evalScripts:true, method:'get', 
          onLoading:function(request){$('tabview_#{update.hash}_' + tab).addClassName('current'); }});"
    javascript_tag(src)
	end
	
  # Autoloads a tab_pane based on the hash in the URL string
  def autoload_tab_pane
    src = "
      if (window.location.hash) {
        tab = window.location.hash.split('#')[1];
        $$('.tab_pane').invoke('hide'); 
        $('tab_pane_' +  tab).show();
        $$('.tabview #tabs li.current').invoke('removeClassName','current'); 
        $$('.horizontal.tabview .current').invoke('removeClassName','current'); 
        $('tab_pane_link_' + tab).addClassName('current'); 
        }"
    javascript_tag(src)
  end
	
  # Container element for a tab pane (for non-ajax tabs)
  def tab_pane(id, options = {}, &block)
    div_id = "tab_pane_#{id.to_s}"
    style = 'display:none' unless options[:selected]
    @tab_panes ||= []
    @tab_panes << div_id
    concat content_tag(:div, capture(&block), :class => "tab_pane", :id => div_id, :style => style)
  end
	
  # # Creates the bar for choosing which tab to show
  # def tab_pane_select(options = {})
  #   return false unless @tab_panes
  #   str = "<div class='tabs'><ul>"
  #   for tab_pane in @tab_panes
  #     str << content_tag(:li, link_to_function
  #   
  # end

  def link_to_tab_pane(title, id, options = {})
    options[:container] ||= "li"
    str = ""
    str << "<#{options[:container]} id='tab_pane_link_#{id.to_s}' class='#{options[:class]}'>" unless options[:link_only]
    str << link_to_function(title, "$$('.tab_pane').invoke('hide'); 
                                    $('tab_pane_#{id.to_s}').show();
                                    $$('.tabview #tabs li.current').invoke('removeClassName','current');
                                    $$('.horizontal.tabview .current').invoke('removeClassName','current'); 
                                    $('tab_pane_link_#{id.to_s}').addClassName('current'); 
                                    window.location.replace('##{id.to_s}');",
                            :class => options[:link_class])
    str << "</#{options[:container]}>" unless options[:link_only]
    str
  end
	
  # Creates a separator
  def separator(text = "or")
    "<span class=\"separator\"> &ndash; #{text} &ndash; </span>"
  end
  
  def menu(title = "menu", options = {}, &block)
    div_id = "menu_panel_" + rand(10000000000).to_s
  	str = link_to_function(title, "Effect.toggle('#{div_id}', 'slide')", :class => 'handle')
  	str << content_tag(:div, capture(&block), :id => div_id, :class => "panel", :style => "display:none")
    concat content_tag(:span, str, :class => "menu #{options[:class]}")
  end
  
  def checkbox_with_label(form, attribute, title = nil)
    title ||= attribute.to_s.humanize
    form.label attribute, form.check_box(attribute) + " " + title
  end
  
  def tooltip(link_text, content, options = {})
    full_link_text = "#{link_text}"
    full_link_text << content_tag(:div, content, :class => 'content')
    options[:class] = options[:class].nil? ? 'tooltip' : "#{options[:class]} tooltip"
    return link_to(full_link_text, options.delete(:url) || nil, options) if options[:url]
    content_tag(:a, full_link_text, options)
  end
  
  # Provides a printable version of the creation and update timestamps for the given object. If the object also
  # has a creator_id and updater_id, this method includes the creator and updater name.
  def object_timestamp_details(object)
    str = ""
    str << "Created " if object.created_at || object.creator
    str << "#{relative_timestamp(object.created_at)} " if object.created_at
    str << "by #{object.creator.firstname_first}" if object.creator rescue nil
    str << " | " unless str.blank?
    str << "Last edited " if object.updated_at || object.updater
    str << "#{relative_timestamp(object.updated_at)} " if object.updated_at
    str << "by #{object.updater.firstname_first}" if object.updater rescue nil
    str
  end

  # time = Time as string, e.g. "13:00"
  # day = Day of week as string, e.g., "wednesday"
  # selected = Initial selected state of the cell. Defaults to false.
  # result_id = DOM ID of the form element to stick the results in
  def time_row_cell(time, day, result_id, selected = false, options = {})
    id = "time_#{time}_#{day.to_s}"
    onMouseDown = "startDragSelect(this, $('#{result_id}'));" unless options[:readonly]
    klass = "selectable_time #{options[:class]} #{"selected" if selected}"
    "<td id=\"#{id}\" onMousedown=\"#{onMouseDown}\" class=\"#{klass}\">#{options[:body]}</td>"
  end

  def pluralize_without_count(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end

  def latex_clean(html, escape_ampersands_twice = false)
    @ptex ||= ProceedingsTex.new
    @ptex.clean(html, escape_ampersands_twice)
  end

  
end













