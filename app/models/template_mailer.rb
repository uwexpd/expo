class TemplateMailer < ActionMailer::Base

  def message(obj, from_text = "", subject_text = "", text = "", link = "", alternate_recipients = nil)         
    @subject    = eval_subject_text(subject_text, obj)
    @recipients = alternate_recipients || (obj.respond_to?("email") ? obj.email : obj.person.email)
    @from       = from_text
    @sent_on    = Time.now
    @body       = { :text => text, :obj => obj, :object => obj, :link => link }
  end

  def html_message(obj, from_text = "", subject_text = "", text = "", link = "", alternate_recipients = nil)
    @subject    = eval_subject_text(subject_text)
    @recipients = alternate_recipients || (obj.respond_to?("email") ? obj.email : obj.person.email)
    @from       = from_text
    @sent_on    = Time.now
    @body       = { :text => text, :obj => obj, :object => obj, :link => link }
    @content_type = "text/html"
  end

  private
  
  def eval_subject_text(subject_text, obj)
    if obj.is_a?(Hash)
      subject = subject_text.to_s.gsub(/\%([a-z0-9_]+).([a-z0-9_]+)\%/) { |a| eval("obj[:#{a[$1]}].#{a[$2]}") rescue nil }
    else
      subject = subject_text.to_s.gsub(/\%([a-z0-9_.]+)\%/) { |a| eval("obj.#{a.gsub!(/\%/,'')}") rescue nil }
    end
    subject
  end
  
end
