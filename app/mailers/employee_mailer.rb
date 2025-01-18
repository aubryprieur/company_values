class EmployeeMailer < ApplicationMailer
  def invitation_email
    @employee = params[:employee]
    @url = activate_employee_url(@employee.invitation_token)

    mail(
      to: @employee.email,
      subject: "Invitation à rejoindre #{@employee.company.name}"
    )
  end
end
