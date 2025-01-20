class EmployeeMailer < ApplicationMailer
  def invitation_email
    @employee = params[:employee]
    @url = activate_employee_url(@employee.invitation_token)

    mail(
      to: @employee.email,
      subject: "Invitation à rejoindre #{@employee.company.name}"
    )
  end

  def survey_invitation_email
    @employee = params[:employee]
    @survey = params[:survey]
    @url = employee_survey_url(@survey)

    mail(
      to: @employee.email,
      subject: "Invitation à participer au sondage #{@survey.title}"
    )
  end

end
