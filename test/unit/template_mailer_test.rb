require 'test_helper'

class TemplateMailerTest < ActionMailer::TestCase
  tests TemplateMailer
  def test_message
    @expected.subject = 'TemplateMailer#message'
    @expected.body    = read_fixture('message')
    @expected.date    = Time.now

    assert_equal @expected.encoded, TemplateMailer.create_message(@expected.date).encoded
  end

end
