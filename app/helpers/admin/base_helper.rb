module Admin::BaseHelper

  def completable_item(title, complete = false, options = {}, &block)
    div_id = "completable_" + rand(10**10).to_s
    show_hidden = options[:hide_when_complete] == false ? false : complete
    complete_class = complete ? "complete" : "incomplete"
    content = content_tag(:b, title)
    content << content_tag(:span, link_to_function("expand", "Effect.toggle('#{div_id}', 'blind', {duration: 0.25})"), :class => "right") if show_hidden
    content << content_tag(:div, capture(&block), :style => ('display:none' if show_hidden), :id => div_id)
    concat content_tag(:li, content, :class => complete_class), block.binding
  end
  
  # Creates a check_box_tag used for selecting an object from a list, in the format +select[:object_class][:object_id]+. Also gives the
  # element a CSS class of +select_check_box+ which can be used to select all of these check boxes on a page. An optional +css_class_id+
  # allows you to add an extra css class that can be used to only select certain check boxes on the page.
  def select_check_box(obj, group = nil, user_options = {})
    options = { :value => "1" }
    options.merge!(user_options)
    css_class = "select_check_box"
    css_class << " #{group}" unless group.nil?
    options[:class] = css_class
    check_box_tag "select[#{obj.class}][#{obj.id}]", options[:value], false, options
  end
  
  # Creates a check_box_tag used for selecting all select_check_boxes on the page. _See select_check_box for options._
  def select_all_check_box(group = nil, options = {})
    css_class = "select_check_box"
    css_class_group = ".#{group}" unless group.nil?    
    field_id = "select_all_check_box_#{group}"
    code = check_box_tag(field_id, "1", false, :class => css_class)
    function = "$$('.#{css_class}#{css_class_group}').each(function(checkbox) 
      { 
        if (checkbox.up(1).visible()) {
          checkbox.checked = $('#{field_id}').checked
        }
      })"
    code << observe_field(field_id, :function => function)
    code
  end
  
  # Creates a link that will submit a form. Specify the ID of the form. Pass a +url+ option parameter to change the action URL
  # of the form first.
  def link_to_submit(link_text, form_id, options = {})
    function = ""
    function << "$('#{form_id.to_s}').action='#{options[:url]}';" if options[:url]
    function << "$('recipient_variant').value='#{options[:recipient_variant]}';" if options[:recipient_variant]
    function << "$('group_variant').value='#{options[:group_variant]}';" if options[:group_variant]
    function << "$('#{form_id.to_s}').method='#{options[:method]}';" if options[:method]
    function << "$('#{form_id.to_s}').submit()"
    link_to_function link_text, function, options[:link_options]
  end
  
  # Creates a link that will insert placeholder text into the specified field. This is used on pages where email templates are
  # being edited to insert placeholders in the form of %attribute%. For example, %person.firstname%.
  def link_to_insert_placeholder_text(field_id, text, display_text = nil, sample_text = nil)
    sample_text = "<span class=\"sample_text\" style=\"display:none\">#{sample_text}</span>" if sample_text
    link_to_function "#{(display_text || text)}#{sample_text}", 
                    "insertAtCursor($('#{field_id}'), '%#{text}%'); Field.focus('#{field_id}')", 
                    :class => 'placeholder_text_link'
  end

  # Creates a link that will send an EXPO email (using the mass emailer) to the given object. If +title+ is passed,
  # that is used for the link text. Otherwise, if +object+ responds to the +email+ method, we use that for the link
  # text. Finally, if neither works, the default link text is "Send EXPO E-mail".
  def link_to_expo_email(object, title = nil, options = {})
    return "" if object.nil?
    other_params = {}
    other_params[:recipient_variant] = options.delete(:recipient_variant)
    other_params[:group_variant] = options.delete(:group_variant)
    options.merge(:title => "Send an EXPO E-mail")
    title = object.respond_to?(:email) ? object.email.to_s : "Send EXPO E-mail" if title.nil?
    link_to title, write_email_path_for(object, other_params), options
  end
  
  # Creates a link that looks like a button, and allows you to specify an icon class. Thus it puts the item inside a an extra element
  # that can be styled separately.
  def button(*args)
    name = args.first
    options = args.second || {}
    html_options = args.third || {}
    css_class = html_options.delete(:class)
    html_options[:class] = 'button'
    name = "<span class='icon-left #{css_class.to_s}'>#{name}</span>"
    link_to(name, options, html_options)
  end
  
  # Constructs a write_email_path with the proper :select attribute for the given object.
  def write_email_path_for(object, other_params = {})
    if object.is_a?(Array)
      ids_hash = {}
      object.each{ |o| ids_hash[o.id] = 1 }
      return admin_communicate_write_email_path(other_params.merge(:select => { object.first.class.to_s => ids_hash }))
    else
      return admin_communicate_write_email_path(other_params.merge(:select => { object.class.to_s => {object.id => 1 }}))
    end
  end
  
  # Creates a check box and label tag suitable for use with the EXPO javascript filters functions.
  def filter_check_box(filter_key, obj_id, label_text, options = {})
    options = { :initial_state => true }.merge(options)
    dom_id = "filter_#{filter_key.to_s}_#{obj_id.to_s.underscore}"
    str = check_box_tag dom_id, true, options[:initial_state], 
                        :class => "#{filter_key.to_s}_filter_checkbox", 
							          :onClick => "changeFilter(this, '#{filter_key.to_s}', '#{obj_id.to_s.underscore}')"
		str << label_tag(dom_id, label_text)
    str
  end

  # Creates a link that will sort based on the given attribute name. If a sort for that column is already applied,
  # create a link that will reverse the sort.
  def link_to_sort(attribute_name, title = nil, options = {})
    order = options.delete(:default) || "ASC"
    if params[:order] && params[:order].include?(attribute_name.to_s)
      order = params[:order].include?("DESC") ? "ASC" : "DESC"
      selected = "selected"
    end
    title = attribute_name.to_s.titleize if title.blank?
    options[:class] = "sort #{options[:class]} #{order} #{selected}"
    options[:title] = "Sort by #{title}"
    link_to "<span class='title'>#{title}</span>", { :order => "#{attribute_name} #{order}"}, options
  end

  # Returns an autocompleting text field to search for a student.
  def student_auto_complete_field(object, method, tag_options = {}, completion_options = {})
    tag_options = tag_options.merge({:indicator => 'global'})
  	model_auto_completer "student_search", "", "#{object}[#{method}]", 0, 
  							{ :submit_on_return => true, 
  							  :append_random_suffix => (tag_options[:append_random_suffix] || false), 
  							  :url => auto_complete_for_student_anything_admin_students_url,
  							  :after_update_element => "function(tf, item, hf, id) { tf.value = tf.value.strip() }" },
  							{ :autocomplete => false, :accesskey => 'f' },
  							{ :skip_style => true, :indicator => tag_options[:indicator] }
    # 
    # observe_field('model_auto_completer_hf', :frequency => 0.5, :function => "$('search-form').submit()" )
  end
  
end


