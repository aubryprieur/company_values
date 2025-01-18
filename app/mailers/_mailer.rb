class SurveyMailer < ApplicationMailer
  def reminder_email(employee, survey)
    @employee = employee
    @survey = survey
    @url = employee_survey_url(@survey)

    mail(
      to: @employee.email,
      subject: "Rappel : Votre avis est important - Sondage #{@survey.title}"
    )
  end
end
