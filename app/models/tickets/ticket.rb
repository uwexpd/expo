class Ticket < ActiveResource::Base
  @project_id = Lighthouse.project_id
  self.site = "http://#{Lighthouse.account}.lighthouseapp.com"
  self.prefix = "/projects/#{@project_id}/"
  headers['X-LighthouseToken'] = Lighthouse.token
  
  # Alias of +number+.
  def id
    number || nil
  end
  
  # Since all comments are created with the "EXPO User" API key, they all appear to come from the same user.
  # To overcome this limitation, we add the name of the EXPO user that created the comment directly into the
  # comment text in the form: "<h4>Comment from John Doe</h4>". This method strips this title out so that we
  # can use it when displaying ticket comments.
  def self.comment_user_name(comment_body)
    return nil if comment_body.blank?
    title = comment_body[/<h4>Comment from (.*)<\/h4>/]
    return nil if title.nil?
    title[$1]
  end
  
  # Strips the username line out of the comment, based on #comment_user_name.
  def self.comment_body_without_user_name(comment_body)
    return nil if comment_body.blank?
    title = comment_body[/<h4>Comment from (.*)<\/h4>/]
    return comment_body if title.nil?
    comment_body.gsub(title, "")
  end
  
end