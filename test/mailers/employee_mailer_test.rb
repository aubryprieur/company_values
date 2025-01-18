require "test_helper"

class EmployeeMailerTest < ActionMailer::TestCase
  test "invitation_email" do
    mail = EmployeeMailer.invitation_email
    assert_equal "Invitation email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
