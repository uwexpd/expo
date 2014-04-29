class TemplateMailer < ActionMailer::Base

  def message(obj, from_text = "", subject_text = "", text = "", link = "", alternate_recipients = nil)
    @subject    = subject_text.to_s.gsub(/\%([a-z0-9_.]+)\%/) { |a| eval("obj.#{a.gsub!(/\%/,'')}") rescue nil }
    @recipients = alternate_recipients || (obj.respond_to?("email") ? obj.email : obj.person.email)
    @from       = from_text
    @sent_on    = Time.now
    @body       = { :text => text, :obj => obj, :object => obj, :link => link }
  end

  def html_message(obj, from_text = "", subject_text = "", text = "", link = "", alternate_recipients = nil)
    @subject    = subject_text.to_s.gsub(/\%([a-z0-9_.]+)\%/) { |a| eval("obj.#{a.gsub!(/\%/,'')}") rescue nil }
    @recipients = alternate_recipients || (obj.respond_to?("email") ? obj.email : obj.person.email)
    @from       = from_text
    @sent_on    = Time.now
    @body       = { :text => text, :obj => obj, :object => obj, :link => link }
    @content_type = "text/html"
  end

end
