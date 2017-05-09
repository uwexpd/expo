require 'pdf/writer'
require 'htmldoc'
require 'fileutils'

=begin
  Generates the Proceedings Report that contains all of the abstracts from a specified Offering. This is specific to the Symposium.
=end
class ProceedingsReport
  include ApplicationHelper
  include ActionView::Helpers
    
  STDOUT.sync = true

  PAPER = "Letter"
  DEFAULT_FONT = "Times-Roman"
  
  DEFAULT_SIZE = 10
  @@TOP_MARGIN = 54
  @@BOTTOM_MARGIN = 54
  @@OUTSIDE_MARGIN = 54
  @@INSIDE_MARGIN = 72
  @@COLUMN_GUTTER = 21
  @@abstract_keep_height = 18
  
  def initialize(offering, admin = false, poster_session_type_id = 1, oral_session_type_id = 2)
    puts "Initializing Proceedings Report for #{offering.title}"
    @offering = offering
    @pdf = ::PDF::Writer.new( :paper => @paper || PAPER )
    @pdf.compressed = true if RAILS_ENV != 'development'
    @pdf.margins_pt(@@TOP_MARGIN, @@INSIDE_MARGIN, @@BOTTOM_MARGIN, @@OUTSIDE_MARGIN)
    @pdf.left_margin = @@INSIDE_MARGIN
    fix_margins
    @x = @pdf.left_margin
    @pdf.select_font DEFAULT_FONT
    @size = DEFAULT_SIZE
    @y_offset = 0
    @pdf.start_columns 2, @@COLUMN_GUTTER
    @admin = admin
    @indexes = { :people => {} }
    @skipped_applications = []
    @skipped_group_members = []
    @exclude_celia = false
    @test = false
    @poster_session_type_id = poster_session_type_id
    @oral_session_type_id = oral_session_type_id
  end

  # Assembles the symposium proceedings in the following order:
  # 
  # * Poster Session 1
  # * Oral Session 1
  # * Poster Session 2
  # * Oral Session 2
  # * Index
  def assemble
    puts "Started at #{Time.now}"
    set_page_number 14

    # Poster Session 1
    add_session @offering.sessions.for_type_in_group(@poster_session_type_id, 1), :include_heading => false
    start_new_page(true)
    start_new_page(true)
    start_new_page(true)
    
    # Oral Session 1
    add_session @offering.sessions.for_type_in_group(@oral_session_type_id, 1).sort_by(&:identifier)
    start_new_page(true)
    start_new_page(true)
    start_new_page(true)
    
    # Poster Session 2
    add_session @offering.sessions.for_type_in_group(@poster_session_type_id, 2), :include_heading => false
    start_new_page(true)
    start_new_page(true)
    start_new_page(true)
    
    # Oral Session 2
    add_session @offering.sessions.for_type_in_group(@oral_session_type_id, 2).sort_by(&:identifier)
    
    start_new_page(true)
    # Index
    add_index(:people)
    start_new_page(true)

    print_skipped_applications

    puts "Ended at #{Time.now}"
  end

  def inspect
    "#<ProceedingsReport:#{report_filename}>"
  end

  def add_abstracts(apps)
    apps.each do |app|
      add_abstract(app) unless @exclude_celia && app.id == 2142
    end
  end

  def add_session(session, options = {})
    session.each{|s| add_session(s, options)} and return if session.is_a?(Array)
    options = { :include_heading => true }.merge(options)
    puts "\n\nAdding session #{session.id}"
    session_heading(session) if options[:include_heading] == true
    apps = session.presenters.sort{|x,y| x.offering_session_order.nil? ? x.lastname_first.strip <=> y.lastname_first.strip : x.offering_session_order.to_i <=> y.offering_session_order.to_i }
    add_abstracts(apps)
  end

  # Outputs the file. Filename is defined by #report_filename.
  def write!
    puts "\nOutputting file..."
    verify_file_path(report_filename)
    if File.open(report_filename, "wb") { |f| f.write @pdf.render }
      return report_filename
    else
      raise "ERROR"
      nil
    end
  end

  # Fetches an abstract and converts the necessary elements into our little markup language so that it can be processed.
  def add_abstract(app, options = {})
    print "\nAdding abstract for ApplicationForOffering #{app.id}:"
    unless app.in_status?(:confirmed) || app.in_status?(:fully_accepted)
      @skipped_applications << app
      print "\n   --> Skipping (application status == '#{app.current_status_name}')"
      return
    end
    print "D" #"   destination, "
    @pdf.add_destination("ApplicationForOffering#{app.id}", "Fit")
    fix_margins
    
    print "T" # "title, "
    if @admin
      @pdf.select_font "Helvetica"
      @pdf.add_text @x-18, @pdf.y, app.id, 6
      @pdf.select_font DEFAULT_FONT
    end
    title = "<b>" + sanitize(app.project_title, :tags => %w(em i font sub sup)).strip + "</b>" #+ " (#{app.id})" # add app.id for proof reading and should comment out when run final version.
    keep_together(title, @size, 0, @@abstract_keep_height)
    parse_and_add_text title
    move_to_newline
    
    print "P" ## "primary presenter name, "
    add_to_index(:people, app.person.lastname_first.strip)
    presenter = "<i>#{app.person.firstname_first(false).strip rescue "(Name Error)"}, "
    reference_quarter ||= @reference_quarter || Quarter.find_by_date(@offering.deadline)
    presenter << "#{app.person.class_standing_description(:recent_graduate_placeholder => "Recent Graduate", :reference_quarter => reference_quarter) rescue nil}"
    presenter << ", #{app.person.majors_list(true, ", ", reference_quarter).strip rescue nil}" unless app.person.majors_list(true, ", ", reference_quarter).blank?
    presenter << ", #{app.person.institution_name rescue nil}" unless app.person.is_a?(Student) || app.person.institution_name == "University of Washington"
    # @pdf.text presenter
    parse_and_add_text presenter
    move_to_newline
    unless app.other_awards.empty?
      print "W"  
      # @pdf.text app.other_awards.sort.collect(&:scholar_title).join(", "), :left => 35
      @x += 35
      parse_and_add_text app.other_awards.sort.collect(&:scholar_title).join(", "), "||", :left, nil, 35
      move_to_newline
    end
        
    # "group members, "
    for group_member in app.group_members
      print "G" 
      # if group_member.confirmed === false
      #   @skipped_group_members << group_member
      #   print "[skip]"
      #   return
      # end
      add_to_index(:people, group_member.lastname_first.strip)
      # @pdf.text group_member.info_detail_line
      parse_and_add_text group_member.info_detail_line
      move_to_newline
      unless group_member.try(:person).try(:awards_list).blank?
        print "w"  
        @x += 35
        parse_and_add_text group_member.try(:person).try(:awards_list)
        move_to_newline
      end
    end
    
    # print "mentors, "
    for mentor in app.mentors
      print "M"
      add_to_index(:people, mentor.lastname_first.strip)
      # @pdf.text "Mentor: #{mentor.info_detail_line}"
      parse_and_add_text "Mentor: #{mentor.info_detail_line(false,true)}"
      move_to_newline
    end
        
    # @pdf.text "</em>"
    parse_and_add_text "</em></i>"    
    
    # print "esel number and location"
    print "EL"
    unless app.easel_number.blank? || app.location_section.blank?
      parse_and_add_text "Easel: ##{app.easel_number}, #{app.location_section.title}"
      move_to_newline
    end    
        
    move_to_newline
        
    unless @skip_abstracts
      print "A"
      # print "abstract "
      parse_and_add_text(app.text("Abstract").body, "||", :full)
      move_to_newline
    end
    
    # move_to_newline
  end

  private

  # Splits a bit of text using "||" as the delimiter and adds it to the PDF. Specify a different delimiter if you'd like.
  def parse_and_add_text(text, delimiter = "||", justification = :left, custom_line_height = nil, indent = 0)
    text = text.to_pdf_octals
    text = text.pdf_symbol_fontize(:prefix => "||%%symbol||", :suffix => "||%%default||")
    text.gsub!("<br>", "||%%newline")
    text.gsub!("</p>", "||%%newline")
    text.gsub!("<p>", "")
    text.gsub!("<sup>", "||%%sup||")
    text.gsub!("</sup>", "||%%default||")
    text.gsub!("<sub>", "||%%sub||")
    text.gsub!("</sub>", "||%%default||")
    text.gsub!("<em>", "<i>")
    text.gsub!("</em>", "</i>")
    text.gsub!("<strong>", "<b>")
    text.gsub!("</strong>", "</b>")
    text_arr = text.split(delimiter)
    # puts text_arr
    add_parsed_array(text_arr, justification, custom_line_height, indent)
  end

  def add_parsed_array(text_array, justification = :left, custom_line_height = nil, indent = 0)
    for t in text_array
      if t[0..1] == '%%'
        case t[2..(t.length)]
        when 'bold':     @pdf.select_font "Times-Bold"
        when 'italic':   @pdf.select_font "Times-Italic"
        when 'symbol':   @pdf.select_font "Symbol", :encoding => "none"
        when 'newline':  move_to_newline
        when 'sup':      @size = DEFAULT_SIZE - 2; @y_offset = 3; @x += 1
        when 'sub':      @size = DEFAULT_SIZE - 2; @y_offset = -3; @x += 1
        else             @pdf.select_font DEFAULT_FONT; @size = DEFAULT_SIZE; @y_offset = 0
        end
      else
        more_to_add = true
        while more_to_add
          t = t.pdf_symbol_fontize(:symbol_only => true)
          new_x = @pdf.text_line_width(t) + @x
          # room_left = @pdf.page_width - @pdf.right_margin - @x
          room_left = @pdf.absolute_right_margin -  @x
          t = @pdf.add_text_wrap(@x, @pdf.y + @y_offset, room_left, t, @size, justification)

          if t.blank?
            more_to_add = false
            @x = new_x
          else
            # if @pdf.y > @pdf.page_height - @pdf.bottom_margin
            #   start_new_page 
            # else
              move_to_newline(custom_line_height || @pdf.font_height)
            # end
            @x = @pdf.left_margin + indent
          end
        end
      end
    end   
    true
  end

  # Creates a session heading for an oral presentation session.
  def session_heading(session)
    puts "\nAdding session heading for session #{session.id}..."    
    if session.location.include?("JHN")
      keep_together(session.title, 14, 32, 100)
    else
      keep_together(session.title, 14, 32, 84)
    end
    add_to_index(:people, session.moderator.person.lastname_first.strip) if session.moderator
    in_column_line
    @size = 14
    move_to_newline(18)
    parse_and_add_text "<b>Session #{session.identifier}</b>", "||", :center
    @size = DEFAULT_SIZE
    move_to_newline
    in_column_line
    move_to_newline(24)
    @size = 14
    parse_and_add_text "<b>#{session.title}</b>", "||", :center, 18
    @size = DEFAULT_SIZE
    move_to_newline(5)
    move_to_newline
    parse_and_add_text "<i>Session Moderator: #{[session.moderator.fullname, session.moderator.department_name].compact.join(", ")}</i>", "||", :center if session.moderator
    move_to_newline
    parse_and_add_text "<b>#{session.location}</b>", "||", :center
    @pdf.select_font DEFAULT_FONT
    move_to_newline
    @size = 9
    move_to_newline
       
    if session.location.include?("JHN")
            parse_and_add_text "<i>Johnson Hall is just west of Mary Gates Hall (MGH). Follow signs leading from the west entrance of MGH; please see map in the back of the program</i>"
            move_to_newline
            move_to_newline
    end
        
    if session.location.include?("Meany Studio Theatre")
            parse_and_add_text "<i>Meany Studio Theatre is a five-minute walk northwest from the main entrance of MGH and across Red Square. Follow signs from the north entrance of MGH; please see map in the back of the program.</i>"
            move_to_newline
            move_to_newline
    end        
    
    parse_and_add_text "* Note: Titles in order of presentation."
    @size = DEFAULT_SIZE
    move_to_newline
    move_to_newline
    
  end

  # If filler is true, then we don't move the pointer down if we're at the top of the page.
  def move_to_newline(height = @pdf.font_height, filler = false)
    fix_margins
    @pdf.move_pointer(height.to_f) unless filler && @pdf.y == @pdf.absolute_top_margin
    @pdf.start_new_page if @pdf.y < @pdf.bottom_margin
    fix_margins
    @x = @pdf.left_margin
  end

  # Starts a new page by calling @pdf.start_new_page and then resets margins to work for booklet printing
  def start_new_page(force = false)
    @pdf.start_new_page(force)
    fix_margins
  end

  # Used to keep lines together (in a very primitive way). Given the content and font size, check if it will go to a new line.
  # If it will, start a new page. Pass a before and after option to include extra PDF userspace units on top or bottom.
  def keep_together(content, size = nil, before = 0, after = 0)
    test_width = @pdf.columns? ? @pdf.column_width : @pdf.absolute_right_margin - @pdf.left_margin
    total_height = before
    more_to_add = true
    t = content
    while more_to_add
      total_height += @pdf.font_height(size)
      t = @pdf.add_text_wrap(0, 0, test_width, t, size, :left, 0, true)
      more_to_add = false if t.blank?
    end
    total_height += after
    # puts "pdf.y = #{@pdf.y}, total_height = #{total_height}, bottom margin = #{@pdf.bottom_margin}"
    if @pdf.y - total_height < @pdf.bottom_margin
      start_new_page
      @x = @pdf.left_margin
      print "[newline:keep]"
    end
  end

  def fix_margins
    if @pdf.columns?
      column_offset = (@pdf.column_number - 1) * (@pdf.column_width + @pdf.column_gutter)
      @pdf.left_margin = (page_number.odd? ? @@INSIDE_MARGIN : @@OUTSIDE_MARGIN) + column_offset
      if page_number.even?
        @pdf.right_margin = ((@pdf.column_count - @pdf.column_number) * (@pdf.column_width + @pdf.column_gutter)) + @@INSIDE_MARGIN
      else
        @pdf.right_margin = ((@pdf.column_count - @pdf.column_number) * (@pdf.column_width + @pdf.column_gutter)) + @@OUTSIDE_MARGIN
      end
    else
      @pdf.left_margin = (page_number.odd? ? @@INSIDE_MARGIN : @@OUTSIDE_MARGIN)
      @pdf.right_margin = (page_number.even? ? @@INSIDE_MARGIN : @@OUTSIDE_MARGIN)
    end
  end

  def in_column_line
    @pdf.line(@pdf.left_margin, @pdf.y, @pdf.left_margin+@pdf.column_width, @pdf.y).stroke
  end

  def set_page_number(number)
    @pdf.start_page_numbering(@pdf.page_width/2, 20, 9, :center, "<PAGENUM>", number)
    fix_margins
  end

  def page_number
    @pdf.which_page_number(@pdf.current_page.page_number).to_i
  end

  # Adds an item to the specified index. There can be many indexes, each defined by a different index key.
  def add_to_index(key, item)
    index = @indexes[key]
    index[item] = index[item].nil? ? [page_number] : index[item] << page_number
  end
  
  # Adds the index to the pdf.
  def add_index(key)
    puts "\nWriting out index..."
    start_new_page
    fix_margins
    @pdf.stop_columns
    @pdf.text "<b>Index of Presenters, Mentors and Moderators</b>", :font_size => 16
    @pdf.start_columns(3)
    @pdf.top_margin = @@TOP_MARGIN + 42
    current_letter = nil
    for item, pages in @indexes[key].sort_by{|k,v| k.to_s.downcase}
      if current_letter != item[0..0].downcase
        move_to_newline(nil, true)
        current_letter = item[0..0].downcase
        fix_margins
        @pdf.text "<b>#{current_letter.upcase}</b>", :font_size => 12
        fix_margins
        move_to_newline(18)
      end
      fix_margins
      # @pdf.add_text @x, @pdf.y, "#{item}  #{pages.uniq.join(", ")}", 9
      @size = 9
      parse_and_add_text("#{item}  #{pages.uniq.join(", ")}", "||", :left, 10, 20)
      move_to_newline(10)
    end
  end

  def print_skipped_applications
    puts "\nSkipped applications:" unless @skipped_applications.empty?
    @skipped_applications.each do |app|
      puts "    " + app.id.to_s.ljust(10) + app.fullname.ljust(40) + app.current_status_name + "\n"
    end
    puts "\nSkipped group members:" unless @skipped_group_members.empty?
    @skipped_group_members.each do |group_member|
      puts "    " + group_member.id.to_s.ljust(10) + group_member.fullname.ljust(40) + group_member.confirmed.to_s + "\n"
    end
  end

  # Verifies that the directories leading up to this filename exist, or if they don't, creates them.
  def verify_file_path(file)
    FileUtils.mkdir_p(File.dirname(file)) unless File.exists?(File.dirname(file))
  end

  def report_filename
    basename = "Proceedings.pdf"
    File.join(RAILS_ROOT, "files", "proceedings_report", @offering.id.to_s, basename)
  end

end