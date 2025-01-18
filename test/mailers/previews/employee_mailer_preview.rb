# Preview all emails at http://localhost:3000/rails/mailers/employee_mailer
class EmployeeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/employee_mailer/invitation_email
  def invitation_email
    EmployeeMailer.invitation_email
  end
end
