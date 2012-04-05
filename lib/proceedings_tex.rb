=begin
  Generates a Proceedings document using the LaTeX processor for PDF output. This is an alternative to using PDF::Writer. 
  
  To use: 
  1. Instantiate it with the related Offering and the ID numbers of the poster session and oral session offering_application_type.
  2. Call #assemble to generate the diffent parts
  3. Then #write! to save the output as both a .tex file and a .pdf.
  
  *Requirements*
  Note that this lib requires latex to be installed along with the rake gem dependency (in environment.rb), as well as htmltolatex for converting HTML markup into LaTeX markup.
  
  To generate the index, you must rerun LaTeX on the .tex document to generate the necessary files. Go to the directory where the files were saved and run:
  1. latex -interaction=nonstopmode ProceedingsTex.tex
  2. makeindex ProceedingsTex.idx
  3. latex -interaction=nonstopmode ProceedingsTex.tex
  4. pdflatex -interaction=nonstopmode ProceedingsTex.tex
  
=end
class ProceedingsTex
  include ApplicationHelper
  include ActionView::Helpers
  include RTeX::Escaping
    
  STDOUT.sync = true
  
  # Instantiate this ProceedingsTex with a specific offering. This offering will be used to gather apps, etc.
  # This also creates the @content String which will hold all of the tex markup as it is created.
  def initialize(offering = nil, poster_session_type_id = 1, oral_session_type_id = 2)
    @offering = offering
    @content = ""
    @skipped_applications = []
    @skipped_group_members = []
    @poster_session_type_id = poster_session_type_id
    @oral_session_type_id = oral_session_type_id
  end

  # Output the files. This outputs a .tex file (simply the contents of @content) and a .pdf file (generated by creating 
  # a new RTeX::Document object based on @content and calling the #to_pdf method). With both files, you can do further 
  # processing on your own, like makeindex.
  def write!
    puts "\nOutputting files..."
    verify_file_path(report_filename(:tex))
    if File.open(report_filename(:tex), "wb") { |f| f.write @content }
      puts report_filename(:tex)
    else
      raise "ERROR"
      nil
    end
    @doc = RTeX::Document.new(@content)
    verify_file_path(report_filename)
    if File.open(report_filename, "wb") { |f| f.write @doc.to_pdf }
      return report_filename
    else
      raise "ERROR"
      nil
    end
  end
  
  # Assemble the pieces of the Proceedings, including the preamble, the sessions and presenters, and the index.
  # You need to manually specify how many blank pages to generate in between each section. This will be based
  # on the number of "filler" pages that the URP staff wants to put in the document. The process for knowing how
  # many pages to add goes like this:
  # 
  # 1. Assemble and generate a "first pass" where you don't care about filler pages. This is just to tell you how
  #    many pages each section will fill up in the final document.
  # 2. Work with staff to determine how many filler pages and where to put them. You may need to pay attention to
  #    left and right-side pages so that things go in the right spot.
  # 3. Once you've figured out how many filler pages go in between each section, edit the code below to reflect.
  # 4. Assemble and generate the ProceedingsTex a second time, and generate the index, and your page numbers should
  #    all line up.
  # 5. Manually edit the page numbers in the the TOC in InDesign to match, then export a PDF.
  # 6. Using a program like Preview or Adobe Acrobat Pro, combine the filler pages (generated from InDesign) with
  #    the PDF pages generated out of EXPO.
  def assemble
    @content << preamble
    
    @content << '\clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage . \clearpage ' + "\n\n"
    
    # # Poster Session 1
    add_session @offering.sessions.for_type_in_group(@poster_session_type_id, 1), :include_heading => false
    @content << '\clearpage . \clearpage . \clearpage ' + "\n\n"
    
    # Oral Session 1
    add_session @offering.sessions.for_type_in_group(@oral_session_type_id, 1).sort_by(&:identifier)
    @content << '\clearpage . \clearpage ' + "\n\n"
    
    # # Poster Session 2
    add_session @offering.sessions.for_type_in_group(@poster_session_type_id, 2), :include_heading => false
    @content << '\clearpage . \clearpage ' + "\n\n"
    # 
    # # Oral Session 2
    add_session @offering.sessions.for_type_in_group(@oral_session_type_id, 2).sort_by(&:identifier)
    
    @content << '\clearpage ' + "\n\n"

    # Index
    @content << '\printindex'

    print_skipped_applications
    @content << "\n" + '\end{document}'
  end

  def inspect
    "#<ProceedingsTex:#{report_filename}>"
  end

  # Returns the @content string, which holds all of the tex markup that has been created thus far.
  def source
    @content
  end

  # Clean up a bit of text. Strip out any instance of "&nbsp;" (we don't want them in the LaTeX output) and
  # pass the output to #convert_html.
  def clean(text = nil, escape_ampersands_twice = false)
    text.gsub!("&nbsp;", " ")
    converted = convert_html(text)
    entity_converted = convert_entities(converted)
    # puts "entity_converted: #{entity_converted}"
    escaped = escape(entity_converted)
    # escaped = escaped.gsub(/&/, '\\\\&')
    escaped = escaped.gsub("&", "\&")
    escaped = escaped.gsub(/&/, '\\\\&') if escape_ampersands_twice
    # puts "escaped: #{escaped}"
    # puts "\n"
    escaped
  end

  # Attempts to convert the bit of HTML that's received as input and convert it into LaTeX markup using htmltolatex.
  # Currently, the path to htmltolatex is hard-coded as <tt>RAILS_ROOT/lib/htmltolatex/htmltolatex</tt> and
  # we +cd+ into this directory before running the command. This method takes the following actions:
  # 
  # # Sanitizes the html input, stripping out all tags except for +em, i, sup,+ and +sub+
  # # Surrounds the html in a +<span>+ so that htmltolatex thinks it's html
  # # Opens a temp file called +htmltolatex+ and writes the html to it
  # # Runs htmltolatex on the temp file and reads it back in and adds it to the stream of latex output.
  def convert_html(html)
    # Sanitize the html and surround in a <span> tag to make it work with htmltolatex better
    html = "<span>" + sanitize(html, :tags => %w(em i sup sub)) + "</span>"

    # Create the temp files and output the html source to the first one
    raw = Tempfile.new('htmltolatex_html')
    output = Tempfile.new('htmltolatex_tex')
    raw << html; raw.flush
    
    # Run htmltolatex on the source
    path = File.join(RAILS_ROOT, "lib", "htmltolatex")
    `cd #{path} && #{File.join(path, "htmltolatex")} -input #{raw.path} -output #{output.path}`

    # Read in the results
    converted = File.open(output.path, "rb") { |f| f.read }
    
    # Close and unlink the files
    raw.close!
    output.close!
    
    # Return the results
    converted
  end

  # Escape text using +replacements+
  def escape(text)
    replacements.inject(text.to_s) do |corpus, (pattern, replacement)|
      corpus.gsub(pattern, replacement)
    end
  end
  
  # -------------------------------------------------------------------------------------------------------------------

  private

  # Define the preamble for the LaTeX file. Sets margins, fonts, and other settings, and then inserts 
  # the <tt>\begin{document}</tt> block.
  def preamble
    '\documentclass[10pt,twocolumn,twoside]{report}
    \usepackage{makeidx}
    \makeindex
    \raggedbottom
    \oddsidemargin 0.25in
    \evensidemargin -0.25in
    \topmargin -0.75in
    \textheight 9.25in
    \setlength{\columnsep}{.25in}
    \usepackage{times}
    \setlength{\parindent}{0in} 
    \begin{document}'
  end
  
  # Given an array of ApplicationForOffering objects, call #add_abstract on each one.
  def add_abstracts(apps)
    apps.each do |app|
      add_abstract(app)
    end
  end

  # Adds an entire OfferingSession (or OfferingSessions, if you pass an array) to the document. This includes:
  # 
  # # Session Heading, unless +options[:include_heading]+ is false
  # # Each application in the session, sorted first by session order and then by student lastname
  def add_session(session, options = {})
    session.each{|s| add_session(s, options)} and return if session.is_a?(Array)
    options = { :include_heading => true }.merge(options)
    puts "\n\nAdding session #{session.id}"
    session_heading(session) if options[:include_heading] == true
    apps = session.presenters.sort{|x,y| x.offering_session_order.nil? ? x.fullname <=> y.fullname : x.offering_session_order.to_i <=> y.offering_session_order.to_i }
    add_abstracts(apps)
  end

  # Adds a single abstract to the content feed. Includes:
  # 
  # * Project title (bold)
  # * Primary presenter details (italic)
  # * Primary presenter scholarships (italics)
  # * Group member details (one per line)
  # * Mentor details (one per line)
  # * Abstract
  # 
  # Any people associated with these items above will be added to the document index.
  # 
  # Note that this method will skip any applications not in the "confirmed" status. These applications will be
  # added to the +@skipped_applications+ array and a notice is printed out to the log.
  def add_abstract(app, options = {})
    print "\nAdding abstract for ApplicationForOffering #{app.id}:"
    unless app.in_status?(:confirmed)
      @skipped_applications << app
      print "\n   --> Skipping (application status == '#{app.current_status_name}')"
      return
    end
    
    print "T" # "title, "
    @content << "\n\n" + '\begin{minipage}{\columnwidth}' + "\n" + '\begin{flushleft}\textbf{' + clean(app.project_title) + '}' + "\n\n"
    
    print "P" ## "primary presenter name, "
    add_to_index(app.person.lastname_first)
    presenter = "#{app.person.firstname_first rescue "(Name Error)"}, "
    reference_quarter ||= @reference_quarter || Quarter.find_by_date(@offering.deadline)
    presenter << "#{app.person.class_standing_description(:recent_graduate_placeholder => "Recent Graduate", :reference_quarter => reference_quarter) rescue nil}, "
    presenter << "#{app.person.majors_list(true, ", ", reference_quarter) rescue nil}"
    presenter << ", #{app.person.institution_name rescue nil}" unless app.person.is_a?(Student)
    @content << '\textit{' + clean(presenter) + '}' + "\n\n"
    
    unless app.other_awards.empty?
      print "W"
      @content << '\hspace{35pt} \textit{'
      @content << clean(app.other_awards.sort.collect(&:scholar_title).join(", "))
      @content << '}' + "\n\n"
    end
        
    # "group members, "
    for group_member in app.group_members
      print "G" 
      # if group_member.confirmed === false
      #   @skipped_group_members << group_member
      #   print "[skip]"
      #   return
      # end
      add_to_index(group_member.lastname_first)
      @content << '\textit{' + group_member.info_detail_line + '}' + "\n\n"
    end
    
    # print "mentors, "
    for mentor in app.mentors
      print "M"
      add_to_index(mentor.lastname_first)
      @content << '\textit{' + "Mentor: #{mentor.info_detail_line}" + '}' + "\n\n"
    end
    @content << '\end{flushleft}' + "\n" + '\end{minipage} \\' + "\n\n" + '\vspace{0.5em}'
    
    unless @skip_abstracts
      print "A"
      @content << clean(app.text("Abstract").body) + "\n"
    end
    
    move_to_newline
  end

  # Creates a session heading for an oral presentation session.
  def session_heading(session)
    puts "\nAdding session heading for session #{session.id}..."
    add_to_index(session.moderator.person.lastname_first)
    @content << '\vspace{1em}' + "\n" + '\begin{minipage}{\columnwidth}' + "\n\n" + '\Large\begin{center}'
    in_column_line
    @content << "\n" + '\vspace{10pt}{\scshape\bfseries{' + "Session #{session.identifier}" + '}}' + "\n\n" + '\vspace{1pt}'
    in_column_line
    @content << '\vspace{10pt}{\scshape\bfseries{' + "#{session.title}" + '}}' + "\n\n" + '\vspace{0.2em}'
    @content << '\normalsize'
    @content << '\textit{'
    @content << "Session Moderator: #{session.moderator.fullname}, #{session.moderator.department_name}" + '}' + "\n\n"
    @content << '\textbf{' + "#{session.location}" + '}' + "\n\n" + '\vspace{0.2em}'
    @content << '\end{center}'
    @content << '\small' + "* Note: Titles in order of presentation.\n\n" + '\end{minipage}' + "\n\n" + '\normalsize \normalsize'
    move_to_newline
  end

  # Adds a +\newpage+ command to the tex content stream.
  def start_new_page(force = false)
    @content << '\newpage'
  end
  
  def in_column_line
    @content << '\hrulefill' + "\n\n"
  end

  # Adds an item to the specified index.
  def add_to_index(item)
    @content << '\index{' + (item) + '}'
  end

  # Insert two line breaks (+\n+) and a +\vspace{1em}+
  def move_to_newline
    @content << "\n\n" + '\vspace{1em}'
  end

  # Print a helpful diagnostic of all of the applications and group members that were skipped in #add_abstract.
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
  
  # Constructs the filename for this report, based in the +files+ directory in your rails root.
  # Pass an extension paramater to use a different file extension. Default is :pdf.
  def report_filename(extension = "pdf")
    basename = "ProceedingsTex." + extension.to_s
    File.join(RAILS_ROOT, "files", "proceedings_report", @offering.id.to_s, basename)
  end
  
  
  def convert_entities(text)
    octals = { "&AElig;" => "\306","&Aacute;" => "\301","&Acirc;" => "\302","&Auml;" => "\304","&Agrave;" => "\300","&Aring;" => "\305","&Atilde;" => "\303","&Ccedil;" => "\307","&Eacute;" => "\311","&Ecirc;" => "\312","&Euml;" => "\313","&Egrave;" => "\310","&ETH;" => "\320","&euro;" => "\200","&Iacute;" => "\315","&Icirc;" => "\316","&Iuml;" => "\317","&Igrave;" => "\314","&Ntilde;" => "\321","&OElig;" => "\214","&Oacute;" => "\323","&Ocirc;" => "\324","&Ouml;" => "\326","&Ograve;" => "\322","&Oslash;" => "\330","&Otilde;" => "\325","&Scaron;" => "\212","&THORN;" => "\336","&Uacute;" => "\332","&Ucirc;" => "\333","&Uuml;" => "\334","&Ugrave;" => "\331","&Yacute;" => "\335","&Yuml;" => "\237","&#x17D;" => "\216","&aacute;" => "\341","&acirc;" => "\342","&acute;" => "\264","&auml;" => "\344","&aelig;" => "\346","&agrave;" => "\340","&amp;" => "\046","&aring;" => "\345","&atilde;" => "\343","&brvbar;" => "\246","&bull;" => "\225","&ccedil;" => "\347","&cedil;" => "\270","&cent;" => "\242","&circ;" => "\210","&copy;" => "\251","&curren;" => "\244","&dagger;" => "\206","&Dagger;" => "\207","&deg;" => "\260","&uml;" => "\250","&divide;" => "\367","&eacute;" => "\351","&ecirc;" => "\352","&euml;" => "\353","&egrave;" => "\350","&hellip;" => "\205","&mdash;" => "\227","&ndash;" => "\226","&eth;" => "\360","&iexcl;" => "\241","&fnof;" => "\203","&szlig;" => "\337","&gt;" => "\76","&laquo;" => "\253","&raquo;" => "\273","&lsaquo;" => "\213","&rsaquo;" => "\233","&iacute;" => "\355","&icirc;" => "\356","&iuml;" => "\357","&igrave;" => "\354","&lt;" => "\074","&not;" => "\254","&macr;" => "\257","&micro;" => "\265","&times;" => "\327","&ntilde;" => "\361","&oacute;" => "\363","&ocirc;" => "\364","&ouml;" => "\366","&oelig;" => "\234","&ograve;" => "\362","&frac12;" => "\275","&frac14;" => "\274","&sup1;" => "\271","&ordf;" => "\252","&ordm;" => "\272","&oslash;" => "\370","&otilde;" => "\365","&para;" => "\266","&middot;" => "\267","&permil;" => "\211","&plusmn;" => "\261","&iquest;" => "\277","&quot;" => "\042","&bdquo;" => "\204","&ldquo;" => "\223","&rdquo;" => "\224","&lsquo;" => "\221","&rsquo;" => "\222","&sbquo;" => "\202","&#x27;" => "\047","&reg;" => "\256","&scaron;" => "\232","&sect;" => "\247","&pound;" => "\243","&thorn;" => "\376","&frac34;" => "\276","&sup3;" => "\263","&tilde;" => "\230","&trade;" => "\231","&sup2;" => "\262","&uacute;" => "\372","&ucirc;" => "\373","&uuml;" => "\374","&ugrave;" => "\371","&yacute;" => "\375","&yuml;" => "\377","&yen;" => "\245","&#x17E;" => "\236","&nbsp;" => " ","&#39;" => '\'' }
   texcodes = { "&plusmn;" => '\pm', "&rarr;" => '\to', "&rArr;" => '\Rightarrow', "&hArr;" => '\Leftrightarrow', "&forall;" => '\forall', "&part;" => '\partial', "&exist;" => '\exists', "&empty;" => '\emptyset', "&nabla;" => '\nabla', "&isin;" => '\in', "&notin;" => '\not\in', "&prod;" => '\prod', "&sum;" => '\sum', "&radic;" => '\surd', "&infin;" => '\infty', "&and;" => '\wedge', "&or;" => '\vee', "&cap;" => '\cap', "&cup;" => '\cup', "&int;" => '\int', "&asymp;" => '\approx', "&ne;" => '\neq', "&equiv;" => '\equiv', "&le;" => '\leq', "&ge;" => '\geq', "&sub;" => '\subset', "&sup;" => '\supset', "&sdot;" => '\cdot', "&Alpha;" => 'Α', "&Beta;" => 'Β', "&Gamma;" => '\Gamma', "&Delta;" => '\Delta', "&Epsilon;" => 'Ε', "&Zeta;" => 'Ζ', "&Eta;" => 'Η', "&Theta;" => '\Theta', "&Iota;" => 'I', "&Kappa;" => 'K', "&Lambda;" => '\Lambda', "&Mu;" => 'M', "&Nu;" => 'N', "&Xi;" => '\Xi', "&Omicron;" => 'O', "&Pi;" => '\Pi', "&Rho;" => 'P', "&Sigma;" => '\Sigma', "&Tau;" => 'T', "&Upsilon;" => '\Upsilon', "&Phi;" => '\Phi', "&Chi;" => 'X', "&Psi;" => '\Psi', "&Omega;" => '\Omega', "&alpha;" => '\alpha', "&beta;" => '\beta', "&gamma;" => '\gamma', "&delta;" => '\delta', "&epsilon;" => '\epsilon', "&zeta;" => '\zeta', "&eta;" => '\eta', "&theta;" => '\theta', "&iota;" => '\iota', "&kappa;" => '\kappa', "&lambda;" => '\lambda', "&mu;" => '\mu', "&nu;" => '\nu', "&xi;" => '\xi', "&omicron;" => 'o', "&pi;" => '\pi', "&rho;" => '\rho', "&sigmaf;" => '\varsigma', "&sigma;" => '\sigma', "&tau;" => '\tau', "&upsilon;" => '\upsilon', "&phi;" => '\phi', "&chi;" => '\chi', "&psi;" => '\psi', "&omega;" => '\omega', "&nbsp;" => ' ' }
   octals.select{|k,v| !texcodes.keys.include?(k)}.each { |html, tex| text = text.gsub(html, tex) unless tex.blank? }
   texcodes.each { |html, tex| text = text.gsub(html, '$' + tex + '$') unless tex.blank? }
   text
  end
  
  # List of replacements
  def replacements
    @replacements ||= [
      # [/([{}])/,    '\\\\\1'],
      #    [/\\/,        '\textbackslash{}'],
      #    [/\^/,        '\textasciicircum{}'],
      #    [/~/,         '\textasciitilde{}'],
      #    [/\|/,        '\textbar{}'],
      #    [/\</,        '\textless{}'],
      #    [/\>/,        '\textgreater{}'],
      [/([_$%#])/, '' + '\1']
    ]
  end
  
end
