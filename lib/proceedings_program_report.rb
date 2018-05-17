class ProceedingsProgramReport < ProceedingsReport
  
  PAPER = "Letter"
  DEFAULT_FONT = "Times-Roman"
  DEFAULT_SIZE = 10
  @@TOP_MARGIN = 36
  @@BOTTOM_MARGIN = 36
  @@OUTSIDE_MARGIN = 158
  @@INSIDE_MARGIN = 54
  @@COLUMN_GUTTER = 21
  @@abstract_keep_height = 54  # was 24

  def initialize(offering, admin = false, poster_session_type_id = 1, oral_session_type_id = 2)
    super(offering, admin, poster_session_type_id, oral_session_type_id)

    @pdf.stop_columns
    @skip_abstracts = true
    @current_even_divider_tab = nil
    @current_odd_divider_tab = nil
    @exclude_celia = true
    
    # @pdf.open_object do |even_margin_line|
    #   @pdf.line(@@OUTSIDE_MARGIN-@@INSIDE_MARGIN, @pdf.page_height, @@OUTSIDE_MARGIN-@@INSIDE_MARGIN, 0).stroke
    #   @pdf.close_object
    #   @pdf.add_object(even_margin_line, :following_even_pages)
    # end
    # @pdf.open_object do |odd_margin_line|
    #   @pdf.line(@pdf.page_width-@@OUTSIDE_MARGIN+@@INSIDE_MARGIN, @pdf.page_height, @pdf.page_width-@@OUTSIDE_MARGIN+@@INSIDE_MARGIN, 0).stroke
    #   @pdf.close_object
    #   @pdf.add_object(odd_margin_line, :following_odd_pages)
    # end

  end
  
  # Assembles the symposium proceedings in the following order:
  # 
  # * Poster Session 1
  # * Oral Session 1
  # * Poster Session 2
  # * Oral Session 2
  # * Index
  # 
  # For process notes about how to get the right number of filler pages, see notes for ProceedingsTex#assemble.
  def assemble
    puts "Started at #{Time.now}"
  
    set_page_number 1
    fix_margins

    poster_type = @offering.poster_application_type
    oral_type   = @offering.oral_application_type
    visual_type = @offering.visual_arts_application_type
    performing_type = @offering.application_types.detect{|t| t.title=="Performing Arts"}

    # Poster Session 1
    puts "\nPoster Session 1"
        change_divider_tab("Poster 1", 4)
        start_new_page(true)
        fix_margins
        add_session @offering.sessions.for_type_in_group(poster_type, 1), :include_heading => false
    
    # Oral Session 1
    puts "\nOral Session 1"
         change_divider_tab
         start_new_page(true)
         start_new_page(true)
         change_divider_tab("Presentation 1", 3)
         start_new_page(true)
         add_session @offering.sessions.for_type_in_group(oral_type, 1).sort_by(&:identifier)

    # Performing Arts
    puts "\nPerforming Arts"
         change_divider_tab
         #start_new_page(true)
         start_new_page(true)
         change_divider_tab("Performing Arts", 2)
         start_new_page(true)
         add_session @offering.sessions.for_type_in_group(performing_type, 1), :include_heading => false
       
    # Poster Session 2
    puts "\nPoster Session 2"
         change_divider_tab
         #start_new_page(true)
         start_new_page(true)
         start_new_page(true)
         change_divider_tab("Poster 2", 1)
         start_new_page(true)
         fix_margins
         add_session @offering.sessions.for_type_in_group(poster_type, 2), :include_heading => false        
    
    # Poster Session 3
    puts "\nPoster Session 3"        
        change_divider_tab
        start_new_page(true)
        start_new_page(true)
        start_new_page(true)
        start_new_page(true)
        start_new_page(true)
        start_new_page(true)
        start_new_page(true) # add one more
        change_divider_tab("Poster 3", 4)
        start_new_page(true)
        fix_margins
        add_session @offering.sessions.for_type_in_group(poster_type, 3), :include_heading => false
        
    # Visual Arts & Design
    puts "\nVisual Arts & Design"
        change_divider_tab
        start_new_page(true)
        start_new_page(true)
        change_divider_tab("Visual Arts & Design", 3)
        start_new_page(true)
        add_session @offering.sessions.for_type_in_group(visual_type, 4), :include_heading => false
        
    # Oral Session 2
    puts "\nOral Session 2"
        change_divider_tab
        start_new_page(true)
        start_new_page(true)
        change_divider_tab("Presentation 2", 2)
        start_new_page(true)
        add_session @offering.sessions.for_type_in_group(oral_type, 2).sort_by(&:identifier)
           
     # Poster Session 4
     puts "\nPoster Session 4"
       change_divider_tab
       start_new_page(true)
       start_new_page(true)
       change_divider_tab("Poster 4", 1)
       start_new_page(true)
       fix_margins
       add_session @offering.sessions.for_type_in_group(poster_type, 4), :include_heading => false       
       
     # Index
     puts "Index"
       change_divider_tab
       start_new_page(true)
       start_new_page(true)
       start_new_page(true)
       start_new_page(true)
       start_new_page(true)
       add_index(:people)
    
    print_skipped_applications

    puts "Ended at #{Time.now}"
  end
  
  def change_divider_tab(title = nil, location_spot = 4)
    @pdf.stop_object(@current_even_divider_tab) if @current_even_divider_tab
    @pdf.stop_object(@current_odd_divider_tab) if @current_odd_divider_tab
    if title
      y = ((@pdf.page_height-20)/4)*(location_spot-1) + 10
      h = (@pdf.page_height-20)/4
      my_fill = Color::GrayScale.new(70)
      text = "<b>#{title}</b>"
      @pdf.open_object do |even_divider_tab|
        @pdf.fill_color! my_fill
        @pdf.rectangle(0, y, 144, h).fill
        @pdf.fill_color! Color::RGB::Black
        my_h = location_spot == 4 ? h+10 : h
        @pdf.add_text 132, y+(my_h/2)-(@pdf.text_width(text,16)/2), text, 16, 90
        @pdf.close_object
        @current_even_divider_tab = even_divider_tab
        @pdf.add_object(even_divider_tab, :following_even_pages)
      end
      @pdf.open_object do |odd_divider_tab|
        @pdf.fill_color! my_fill
        x = @pdf.page_width-144
        @pdf.rectangle(x, y, 144, h).fill
        @pdf.fill_color! Color::RGB::Black
        @pdf.add_text x+12, y+(h/2)+(@pdf.text_width(text,16)/2), text, 16, 270
        @pdf.close_object
        @current_odd_divider_tab = odd_divider_tab
        @pdf.add_object(odd_divider_tab, :following_odd_pages)
      end
    end
  end
  
  def in_column_line
    fix_margins
    page_offset = page_number.odd? ? -@@INSIDE_MARGIN : @@OUTSIDE_MARGIN-@@INSIDE_MARGIN*2
    center = @pdf.page_width/2 + page_offset
    @pdf.line(center-125, @pdf.y, center+125, @pdf.y).stroke
    fix_margins
  end
    
  def report_filename
    basename = "Program.pdf"
    File.join(RAILS_ROOT, "files", "proceedings_report", @offering.id.to_s, basename)
  end
  
end