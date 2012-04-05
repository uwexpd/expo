require File.dirname(__FILE__) + '/../test_helper'

class ApplyMailerTest < ActionMailer::TestCase
  tests ApplyMailer
  def test_status_update
    @expected.subject = 'ApplyMailer#status_update'
    @expected.body    = read_fixture('status_update')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ApplyMailer.create_status_update(@expected.date).encoded
  end

end
