require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "password_reminder" do
    @expected.subject = 'UserMailer#password_reminder'
    @expected.body    = read_fixture('password_reminder')
    @expected.date    = Time.now

    assert_equal @expected.encoded, UserMailer.create_password_reminder(@expected.date).encoded
  end

end
