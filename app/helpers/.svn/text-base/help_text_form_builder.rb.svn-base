class HelpTextFormBuilder < ActionView::Helpers::FormBuilder

  helpers = field_helpers +
            %w{date_select datetime_select time_select} +
            %w{collection_select select country_select time_zone_select} -
            %w{hidden_field label fields_for radio_button} # Don't decorate these

  helpers.each do |name|
    define_method(name) do |field, *args|
      help_text = ModelHelpText.for(@object, field)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options = args[0] if name == "check_box" && !args[0].nil?
      return super if options[:default]
      label = label(field, options.delete(:label) || (help_text.title rescue nil) || field.to_s.humanize, :class => options.delete(:label_class))
      after = options[:after] || ""
      caption = ""; example = "";
      caption << "<div class=\"caption\">" + options.delete(:caption).to_s + "</div>" if options.include?(:caption)
      if help_text
        caption << "<div class=\"caption\">" + help_text.caption + " "
        unless help_text.example.blank?
          dom_id = "model_help_text_example_#{help_text.id}"
          example << @template.link_to_function("Show me an example", "Effect.toggle('#{dom_id}', 'blind')", :class => "example")
          example << @template.content_tag(:div, help_text.example, 
                                                :style => "display:none", :class => "example box",
                                                :id => dom_id)
        end
        caption << "</div>"
      end
      # @template.content_tag(:dt, label) + @template.content_tag(:dd, super + caption)
      @template.content_tag(:div, label + caption + super + after) + example
    end
  end
  
  define_method("label_with_caption") do |field, *args|
    help_text = ModelHelpText.for(@object, field)
    label = label(field, options.delete(:label) || (help_text.title rescue nil) || field.to_s.humanize, :class => options.delete(:label_class))
    caption = "";
    caption << "<div class=\"caption\">" + options.delete(:caption).to_s + "</div>" if options.include?(:caption)
    caption << "<div class=\"caption\">" + help_text.caption + "</div>" if help_text
    label + caption
  end
  
end