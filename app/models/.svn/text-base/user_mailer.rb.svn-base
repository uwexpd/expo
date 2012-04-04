class UserMailer < ActionMailer::Base
  

  def password_reminder(user, sent_at = Time.now)
    subject    'Password Reminder'
    recipients user.email
    from       CONSTANTS[:system_help_email]
    sent_on    sent_at
    body       :user => user,
                :password_reset_link => reset_password_url(user.id, user.token.to_s, :host => CONSTANTS[:base_url_host])
  end

end
