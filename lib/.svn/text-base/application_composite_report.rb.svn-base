require 'pdf/writer'
require 'htmldoc'
require 'fileutils'

=begin
  Creates or retrieves a custom composite report pertaining to an ApplicationForOffering. Each application has access to this functionality through the +composite_report+ method. There is only one public method, +pdf+, which takes paramaters of the application parts that should be included in the PDF report. Options are:
  
  * :scoring - A scoring/comment sheet that can be used by reviewers.
  * :application_review - Uses HTMLDoc to duplicate the "Application Details" tab.
  * :files - All files (usually essays) that the applicant uplaoded. Auto-generates the PDF version if needed.
  * :mentor_letters - All letters that the applicant's mentor(s) uplaoded. Auto-generates the PDF version if needed.
  * :transcript - Uses HTMLDoc to duplicate the transcript display on the "Transcript" tab.
  * :all - includes all of the above
=end
class ApplicationCompositeReport
  
  def initialize(application_for_offering, application_reviewer = nil, offering_interview_interviewer = nil)
    @application_for_offering = application_for_offering
    @application_reviewer = application_reviewer
    @offering_interview_interviewer = offering_interview_interviewer
  end
  
  # Generates the PDF report using the parts requested.
  def pdf(*include_parts)
    
    # Allow for an ":all" parameter
    include_parts = [:application_review, :files, :mentor_letters, :transcript, :scoring] if include_parts == [:all]

    # Reorder include_parts if they are out of order
    include_parts = reorder_parts(include_parts)

    puts "Creating composite report with the following parts:"
    puts "   #{include_parts.join(", ")}"
    
    # Return a cached version if it exists
    if !stale?(include_parts)
      puts "Returning cached report file"
      puts "   Report created: #{File.mtime(report_filename(include_parts)) rescue "never"}"
      puts "   Application updated: #{@application_for_offering.updated_at}"
      return report_filename(include_parts)
    end
    
    # For each part of the application, get or generate the filenames of the PDF files we'll be combining.
    parts = []
    for part in include_parts.flatten
      parts << get_part(part)
    end
    parts.flatten!
    
    # Check that the parts filenames exist
    parts.delete_if {|p| !File.exists?(p.to_s) }
    puts "ERROR: No files to combine" if parts.empty?

    puts "Combining the following files:"
    parts.each{|p| puts "   #{p}"}
    
    # Combine the PDFs together into one report
    output = report_filename(include_parts)
    verify_file_path(output)
    puts "Outputting to:"; puts "   #{output}"
    res = `pdftk #{parts.collect{|p| p.gsub(" ", "\ ")}.join(" ")} cat output #{output}`
    if $?.success?
      puts "Successfully generated report."
      return output
    else
      puts "Error creating report file: #{res} #{$?}"
      return $?
    end
  end
  
  # Returns true if the generated report (that matches the requested parts) is older than the application_for_offering's updated_at.
  def stale?(include_parts)
    return true if !exists?(include_parts)
    filetime = File.mtime(report_filename(include_parts))
    return true if filetime < @application_for_offering.updated_at
    return true if @application_reviewer && include_parts.include?(:scoring) && filetime < @application_reviewer.updated_at
    return true if @offering_interview_interviewer && include_parts.include?(:scoring) && filetime < @offering_interview_interviewer.updated_at
    false
  end

  # Returns true if this report file exists
  def exists?(include_parts)
    File.exists?(report_filename(include_parts))
  end

  # Retrieve the requested application part, or generate it if necessary. Returns a filename.
  def get_part(part)
    case part
    when :stamp
      File.exists?(part_filename(part)) ? part_filename(part) : generate_pdf_stamp!
    when :application_review
      # File.exists?(part_filename(part)) ? part_filename(part) : generate_part!(part)
      generate_part!(part)
    when :scoring
      generate_part!(part)
    when :transcript
      # File.exists?(part_filename(part)) ? part_filename(part) : generate_part!(part)
      generate_part!(part)
    when :files
      files = []
      @application_for_offering.files.each do |f|
        if f.file && f.file.original.exists?
          files << (f.file.pdf.exists? ? stamp_pdf_if_needed(f.file.pdf.path) : convert_to_pdf!(f.file))
        end
      end
      files
    when :mentor_letters
      letters = []
      @application_for_offering.mentors.each do |m|
        if m.letter && m.letter.original.exists?
          letters << (m.letter.pdf.exists? ? stamp_pdf_if_needed(m.letter.pdf.path) : convert_to_pdf!(m.letter))
        end
      end
      letters
    end
  end

  # Gets the filename for the requested application part
  def part_filename(part)
    if part == :scoring
      reviewer_bits = []
      reviewer_bits << "r#{@application_reviewer.id.to_s}" if @application_reviewer
      reviewer_bits << "i#{@offering_interview_interviewer.id.to_s}" if @offering_interview_interviewer
    end
    part_name = part == :scoring ? "scoring_#{reviewer_bits.join("_")}" : part.to_s
    File.join(RAILS_ROOT, "files", "application_composite_report", @application_for_offering.id.to_s, "parts", part_name + ".pdf")
  end
  
  # Returns the full report filename, which includes a hash of the included_parts array for differentiation between versions.
  def report_filename(include_parts)
    reviewer_bits = []
    reviewer_bits << "r#{@application_reviewer.id.to_s}" if @application_reviewer
    reviewer_bits << "i#{@offering_interview_interviewer.id.to_s}" if @offering_interview_interviewer
    app_reviewer_bit = "_#{reviewer_bits.join("_")}" unless reviewer_bits.empty?
    basename = "Report_#{@application_for_offering.id.to_s}#{app_reviewer_bit.to_s}_#{include_parts.hash.to_s}.pdf"
    File.join(RAILS_ROOT, "files", "application_composite_report", @application_for_offering.id.to_s, basename)
  end

  protected
  
  # Generate a new PDF version of the specified application part. Returns a File.
  def generate_part!(part)
    puts "Generating part: #{part}"
    data = case part
    when :transcript
      dummy_render({:partial => "admin/apply/section/transcript", :locals => {:print_only => true, :audience => :reviewer}}, 
                   {:app => @application_for_offering})
    when :application_review
      dummy_render({:partial => "admin/apply/section/application_review", :locals => {:audience => :download}}, {:app => @application_for_offering})
    when :scoring
      dummy_render({:partial => "admin/apply/section/scoring"}, 
                   {:app => @application_for_offering, 
                     :application_reviewer => @application_reviewer,
                     :offering_interview_interviewer => @offering_interview_interviewer})
    end
    verify_file_path(part_filename(part))
    pdf = PDF::HTMLDoc.new
    pdf.set_option :bodycolor, :white
    pdf.set_option :toc, false
    pdf.set_option :portrait, true
    pdf.set_option :links, false
    pdf.set_option :webpage, true
    pdf.set_option :left, '2cm'
    pdf.set_option :right, '2cm'
    pdf.set_option :outfile, part_filename(part)
    pdf << data
    if pdf.generate
      stamp_pdf!(part_filename(part))
    else
      nil
    end
  end
  
  # Use DocumentConverter to convert a file to PDF using the process!(:convert_to_pdf) method. Expects an UplaodedFile object.
  # Returns the filename of the new file upon success, or nil if failure.
  def convert_to_pdf!(file)
    puts "Converting to PDF: #{file}"
    file.process!(:convert_to_pdf) ? file.pdf.path : nil
  end
  
  # Creates a PDF "stamp" that can be used to label every page when combining using pdftk.
  def generate_pdf_stamp!
    pdf = ::PDF::Writer.new('Letter')
    pdf.select_font "Helvetica"
    pdf.add_text 20, pdf.y+10, "#{@application_for_offering.offering.title}", 9
    pdf.add_text 20, pdf.y-2, "<b>Applicant: #{@application_for_offering.fullname}</b>", 11
    pdf.fill_color Color::RGB::Red
    pdf.add_text_wrap 0, pdf.y+10, 590, "<b>CONFIDENTIAL</b>", 11, :right
    pdf.fill_color Color::RGB::Black
    pdf.add_text_wrap 0, pdf.y, 590, "Destroy by #{@application_for_offering.offering.destroy_by}", 7, :right
    verify_file_path(part_filename(:stamp))
    if File.open(part_filename(:stamp), "wb") { |f| f.write pdf.render }
      return part_filename(:stamp)
    else
      nil
    end
  end
  
  # Adds the PDF stamp to the requested file
  def stamp_pdf!(file)
    puts "Stamping pdf: #{file}"
    `cp #{file} #{file}-unstamped`
    `pdftk #{file}-unstamped stamp #{get_part(:stamp)} output #{file}`
    return $?.success? ? file : $?
  end
  
  # Checks to see if there is an unstamped version of the file (+filename.pdf-unstamped+). If it exists, then we assume that
  # the file itself has already been stamped and we don't need to stamp the file. If the unstamped version does not exist, however,
  # then do nothing. Either way, returns the original filename back (which should now be properly stamped).
  def stamp_pdf_if_needed(file)
    stamp_pdf!(file) unless File.exists?("#{file}-unstamped")
    file
  end
  
  # Uses ActionView to render using the specified options, while assigning the specified instance variables in +assigns+.
  # Based on the comments at http://blog.choonkeat.com/weblog/2006/08/rails-calling-r.html
  def dummy_render(options = {}, assigns = {})
    puts "   Rendering #{options[:partial]}"
    av = ActionView::Base.new(Rails::Configuration.new.view_path)
    assigns.each{ |key,value| av.assigns[key] = value }
    av.render(options)
  end
  
  # Verifies that the directories leading up to this filename exist, or if they don't, creates them.
  def verify_file_path(file)
    FileUtils.mkdir_p(File.dirname(file)) unless File.exists?(File.dirname(file))
  end
  
  # Re-orders the array of parts to be the correct order.
  def reorder_parts(parts)
    order = { :scoring => 0, :application_review => 1, :files => 2, :mentor_letters => 3, :transcript => 4 }
    ordered_parts = []
    parts.flatten.each{|p| ordered_parts.insert(order[p], p)}
    ordered_parts.compact
  end
  
  def puts(s)
    Rails.logger.info(s) unless Rails.logger.nil?
    Kernel.print(s + "\n")
  end
  
end