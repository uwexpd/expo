module MentorHelper
  
  # Formats the mentor instructions from the database to include dynamic fields, using this procedure:
  #  1. Uses auto_link to add link tags, etc.
  #  2. Writes the note about whether the student has waived their right to see the letter once uploaded.
  #  3. Writes the note about viewing the student's application, if they have given the mentor access.
  #  4. Substitutes variables +%variable%+ syntax with values from the @mentee variable.
  def format_mentor_instructions(text)
    text = auto_link(text)
    waived_right_note = case @mentee_application_record.waive_access_review_right
    when true
      "Please note that #{@mentee.firstname} has waived #{@mentee.his_her} right to view the letter that you 
        provide here and #{@mentee.he_she} will not be able to read your letter once submitted."
    else
      "Please note that #{@mentee.firstname} has <strong>not</strong> waived #{@mentee.his_her} right to view
        the letter that your provide here and #{@mentee.he_she} will be able to view a copy of this letter if
        #{@mentee.he_she} desires."
    end
    
    released_access_note = case @mentee_application.mentor_access_ok
    when true
      "In addition, #{@mentee.firstname} has provided access to #{@mentee.his_her} application for your information.
        You can use the links on the right to review the application details at any time."
    else
      "" # don't show anything if there's no access to the application record.
    end
    text.gsub!("%waived_right_note%", waived_right_note)
    text.gsub!("%released_access_note%", released_access_note)
    text.gsub!(/\%([a-z0-9_.]+)\%/) { |a| eval("@mentee.#{a.gsub!(/\%/,'')}") }
  end
  
  def upload_title(file)
    file.nil? ? "File to Upload:" : "Upload a Different File:"
  end
  
end
