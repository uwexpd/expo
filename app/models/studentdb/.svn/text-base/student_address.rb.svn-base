# Contains all address information (mail, email, phone) for all student entities in UWSDB.
class StudentAddress < StudentInfo
  set_table_name "addresses"
  set_primary_key "system_key"
  belongs_to :student_record

  ADDRESS_FIELDS = %w(line_1 line_2 city state zip_5 zip_4 country postal_cd)
  
  def full_local_address(display = 'html', sep = nil)
    # separator = display == 'html' ? "<br>" : ", "
    # separator = separator.nil? ? separator : sep
    separator = (display == 'html' && sep.nil?) ? "<br>" : sep.to_s
    addr = "#{local_line_1}".strip.humanize.titleize
    addr << separator << "#{local_line_2}".strip.humanize.titleize unless local_line_2.blank?
    addr << separator << "#{local_city}".strip.humanize.titleize unless local_city.blank?
    addr << " #{local_state}" unless local_state.blank?
    addr << " #{local_zip_5}" unless local_zip_5.blank?
    addr << "-#{local_zip_4}" unless local_zip_4.blank?
    addr << separator << "#{local_country}" unless local_country.blank?
    addr << " #{local_postal_cd}" unless local_postal_cd.blank?
    addr
  end

  def full_permanent_address(display = 'html', sep = nil)
    # separator = display == 'html' ? "<br>" : ", "
    # separator = separator.nil? ? separator : sep
    separator = (display == 'html' && sep.nil?) ? "<br>" : sep.to_s
    addr = "#{perm_line_1}".strip.humanize.titleize
    addr << separator << "#{perm_line_2}".strip.humanize.titleize unless perm_line_2.blank?
    addr << separator << "#{perm_city}".strip.humanize.titleize unless perm_city.blank?
    addr << " #{perm_state}" unless perm_state.blank?
    addr << " #{perm_zip_5}" unless perm_zip_5.blank?
    addr << "-#{perm_zip_4}" unless perm_zip_4.blank?
    addr << separator << "#{perm_country}" unless perm_country.blank?
    addr << " #{perm_postal_cd}" unless perm_postal_cd.blank?
    addr
  end

  # Returns the selected address with a separator in between each field. Useful for exporting to Excel files, for instance.
  def for_export(location, separator)
    ADDRESS_FIELDS.collect{ |p| part(location, p)}.join(separator)
  end
  
  # Returns the selected address with a separator in between each printed line. Useful for printing on award letters, for instance.
  def for_print(location, separator = "<br>")
    return full_local_address('text', separator) if location_title(location) == "local"
    return full_permanent_address('text', separator) if location_title(location) == "perm"
    nil
  end
  
  protected
  
  def part(location, part)
    eval("#{location_title(location)}_#{part}").strip.humanize.titleize rescue nil
  end
  
  def location_title(location)
   return "perm" if location == "permanent"
   return "local" if location == "local"
   location
  end
  
end
