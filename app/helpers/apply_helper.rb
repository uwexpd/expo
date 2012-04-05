module ApplyHelper
  
  def add_other_award_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :other_awards, :partial => 'other_award', :object => ApplicationOtherAward.new
    end
  end
  
  def add_other_link(name, div, partial, object)
    link_to_function name do |page|
      page.insert_html :bottom, div, :partial => partial, :object => eval("#{object}.new")
    end
  end
  
  def add_award_link(name, div, partial, user_application)
    link_to_function name do |page|
      page.insert_html  :bottom, div, 
                        :partial => partial, 
                        :object => user_application.awards.create(:amount_requested => user_application.offering.default_award_amount)
    end
  end
  
  
  def welcome_line
    if @user_application.new_record?
      intro = "Welcome,"
    else
      intro = case @user_application.status.name
      when "new"
      	"Welcome,"
      when "in_progress"
        "Welcome back,"
      when "submitted"
        "Thank you for submitting your application,"
      else
        "Welcome back,"
      end
    end
    "#{intro} #{current_user.person.firstname}!"
  end
  
  def start_button_text
    intro = case @user_application.status.name
    when "new"
    	"Start"
    when "in_progress"
      "Continue"
    else
      "View"
    end
    "#{intro} Your Application"
  end
  
  def page_to_start
    @user_application.current_page.nil? ? 1 : @user_application.current_page.ordering
  end

  # Generates a caption element and computes any generated content within it (e.g., converts %foo% into "bar")
  def display_computed_caption(caption)
    caption.gsub!(/\%([a-z0-9_.]+)\%/) { |a| eval("@user_application.#{a.gsub!(/\%/,'')}") }
    content_tag('p', caption, :class => 'question_caption')
  end
  
  def upload_title(question_file)
    question_file.file.nil? ? "File to Upload:" : "Upload a Different File:"
  end

  # Provides a link of class "help" that opens a popup with the help_text for the supplied question.
  def help_link(question)
    return nil if question.help_text.blank?
    link_text = question.help_link_text.blank? ? "Help" : question.help_link_text
    link_to link_text, 
  				apply_help_url(question.offering, question), 
  				:popup => ['help', 'height=500,width=400,toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=1,resizable=1'],
  				:class => 'help'
  	
  end
  
end

