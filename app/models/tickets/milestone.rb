class Milestone < ActiveResource::Base
  @project_id = Lighthouse.project_id
  self.site = "http://#{Lighthouse.account}.lighthouseapp.com"
  self.prefix = "/projects/#{@project_id}/"
  headers['X-LighthouseToken'] = Lighthouse.token
  
  # Returns the tickets for this milestone.
  def tickets
    Ticket.find(:all, :params => { :q => "milestone:\"#{title}\" state:open sort:priority" })
  end
  
end