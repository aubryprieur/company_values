class QvtTheme < ApplicationRecord
  has_many :qvt_questions, dependent: :destroy
  validates :name, presence: true

  def completion_status(survey, employee)
    completed_count = completed_questions(survey, employee)
    total_count = qvt_questions.count

    return :completed if completed_count == total_count
    return :in_progress if completed_count > 0
    :not_started
  end

  def completed_questions(survey, employee)
    employee.qvt_responses
           .where(survey: survey)
           .where(qvt_question_id: qvt_questions.pluck(:id))
           .count
  end

  def last_response_time(survey, employee)
    employee.qvt_responses
           .where(survey: survey)
           .where(qvt_question_id: qvt_questions.pluck(:id))
           .maximum(:updated_at)
  end

  def completion_percentage(survey, employee)
    total = qvt_questions.count
    return 0 if total.zero?

    completed = completed_questions(survey, employee)
    (completed.to_f / total * 100).round
  end
end
