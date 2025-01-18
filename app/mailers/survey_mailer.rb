class SurveyMailer < ApplicationMailer
  def reminder_email(employee, survey)
    @employee = employee
    @survey = survey
    @company = survey.company
    @url = employee_surveys_url

    mail(
      to: @employee.email,
      subject: "Rappel : Votre participation au sondage #{@survey.title} est attendue"
    )
  end
end
