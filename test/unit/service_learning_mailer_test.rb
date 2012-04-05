require File.dirname(__FILE__) + '/../test_helper'

class ServiceLearningMailerTest < ActionMailer::TestCase
  tests ServiceLearningMailer
  def test_registration_complete
    @expected.subject = 'ServiceLearningMailer#registration_complete'
    @expected.body    = read_fixture('registration_complete')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ServiceLearningMailer.create_registration_complete(@expected.date).encoded
  end

end
