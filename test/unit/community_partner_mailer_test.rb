require File.dirname(__FILE__) + '/../test_helper'

class CommunityPartnerMailerTest < ActionMailer::TestCase
  tests CommunityPartnerMailer
  def test_login_link
    @expected.subject = 'CommunityPartnerMailer#login_link'
    @expected.body    = read_fixture('login_link')
    @expected.date    = Time.now

    assert_equal @expected.encoded, CommunityPartnerMailer.create_login_link(@expected.date).encoded
  end

end
