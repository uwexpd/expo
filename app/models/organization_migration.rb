class OrganizationMigration < ActiveRecord::Base #:nodoc:

  def self.migrate
    OrganizationMigration.transaction do
      i = 0
      self.find(:all).each do |o|
        i += 1
        n = Organization.new
      
        # save general org info
        n.name = o.name
        n.mailing_line_1 = o.address1
        n.mailing_line_2 = o.address2
        n.mailing_city = o.city
        n.mailing_state = "Washington" # <---- it turns out that all the orgs are in WA anyway
        n.mailing_zip = o.zip
        n.website_url = o.clean_url # <------------ need to clean url
        n.mission_statement = o.overview
        n.approved = true
      
        # save so that we can build associations
        n.save!
      
        # create contact 1
        c1 = n.contacts.create
        phone = o.contact1_phone.to_s if o.contact1_phone
        phone << o.contact1_extension if o.contact1_phone && o.contact1_extension
        c1.person = { :firstname => Person.get_first_and_last(o.contact1_name)[0], 
                      :lastname => Person.get_first_and_last(o.contact1_name)[1], 
                      :phone => phone,
                      :fax => o.contact1_fax,
                      :email => o.contact1_email }
        c1.person.save!
        c1.save!
      
        # create contact 2
        c2 = n.contacts.create
        c2.person = { :firstname => Person.get_first_and_last(o.contact2_name)[0], 
                      :lastname => Person.get_first_and_last(o.contact2_name)[1], 
                      :phone => o.contact2_phone, 
                      :email => o.contact2_email }
        c2.person.save!
        c1.save!
      
        # create site notes
        o.split_site_notes.each do |note|
          n.notes.create  :note => note[:note], 
                          :created_at => (Date.parse(note[:date], true) rescue nil),
                          :updated_at => (Date.parse(note[:date], true) rescue nil),
                          :creator_name => note[:initials].upcase
        end
        
        # finally, active the organization for Autumn 2008
        OrganizationQuarter.find_or_create_by_organization_id_and_quarter_id(n.id, Quarter.find_by_abbrev("AUT2008").id)
        
      end
      return "Migrated #{i} organizations."
    end
    "Failed."
  end
  
  def self.migrate_titles
    OrganizationMigration.transaction do
      count = 0; success = 0;
      self.find(:all).each do |o|
        count += 1
        p = Person.find_by_firstname_and_lastname_and_email(
                Person.get_first_and_last(o.contact1_name)[0], 
                Person.get_first_and_last(o.contact1_name)[1],
                o.contact1_email)
        if p
          p.update_attribute(:title, o.contact1_title)
          success += 1
        end
      end
      "Count: #{count}. Success: #{success}."
    end
  end
  
  def split_site_notes
    return [] if site_notes.blank?
    records = [] # will hold the site notes (each will be a hash of date, initials, notes)
    date_regex = /\d+[\.\/]\d+[\.\/]\d+/ # used to find the date in each site note
    note_regex = /(#{date_regex})\s*\(([\w\s]+)\)\s*([\W\w]*)/
    separator = "|SEPARATOR|" # we use a separator tag that we can insert in between each site note and then separate on that later
    site_notes.gsub!(date_regex, separator + '\0')
    site_notes.split(separator).each do |note|
      if parts = note.match(note_regex)
        records << {:date => parts[1], :initials => parts[2], :note => parts[3].strip}
      end
    end
    records
  end

  def split_site_notes_new
    return [] if site_notes.blank?
    records = [] # will hold the site notes (each will be a hash of date, initials, notes)
    date_regex = /\d+[\.\/]\d+[\.\/]\d+/ # used to find the date in each site note
    note_regex = /(#{date_regex})\s*\((.+)\)\s*([\W\w]*)/
    separator = "|SEPARATOR|" # we use a separator tag that we can insert in between each site note and then separate on that later
    site_notes.gsub!(date_regex, separator + '\0')
    site_notes.split(separator).each do |note|
      if parts = note.match(note_regex)
        records << {:date => parts[1], :initials => parts[2], :note => parts[3].strip}
      end
    end
    records
  end


  # Since Access stores addresses as name#url#, we strip the section inside the #'s, unless it doesn't have anything in the name section.
  def clean_url
    return nil if url.blank?
    (url[0,1] == '#' ? url.gsub('#','') : url.gsub(/(#[\W\w]*#)/, "")).strip
  end
  
end


=begin
  - use contact1 phone as main phone?
  - don't store fax currently. should we?
=end