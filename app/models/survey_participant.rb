# app/models/survey_participant.rb
class SurveyParticipant < ApplicationRecord
  belongs_to :survey
  belongs_to :employee

  enum :status, { pending: 0, responded: 1 }

  def has_responded?
    if survey.company_values?
      employee.responses
             .joins(company_value: :surveys)
             .where(surveys: { id: survey.id })
             .exists?
    else
      employee.qvt_responses
             .where(survey: survey)
             .exists?
    end
  end

end
