class Survey < ApplicationRecord
  belongs_to :company
  has_and_belongs_to_many :company_values
  has_many :responses, through: :company_values
  has_many :custom_values, dependent: :destroy
  has_many :qvt_responses, dependent: :destroy
  has_many :survey_participants
  has_many :employees, through: :survey_participants

  enum :survey_type, { company_values: 0, qvt: 1 }

  validates :title, presence: true
  validates :end_date, presence: true
  validates :company_values, presence: true, if: :company_values?
  validates :survey_type, presence: true
  validate :company_survey_limit

  def closed?
    end_date < Time.current
  end

  def calculate_rankings
    company_values.map do |value|
      avg_rating = value.responses.average(:rating).to_f.round(2)
      {
        value: value,
        average_rating: avg_rating,
        response_count: value.responses.count
      }
    end.sort_by { |r| -r[:average_rating] }
  end

  def completed_by?(employee)
    # Vérifie que chaque valeur du sondage a une réponse
    company_values.all? do |value|
      employee.responses.exists?(company_value: value)
    end
  end

  def qvt_responses
    QvtResponse.where(survey: self)
  end

  def completion_percentage(employee)
    return 0 unless qvt?

    total_questions = QvtTheme.joins(:qvt_questions).select('qvt_questions.id').distinct.count
    return 0 if total_questions.zero?

    completed_questions = qvt_responses.where(employee: employee).count
    ((completed_questions.to_f / total_questions) * 100).round(1)
  end

  def qvt_completion_rate
    return 0 if company.employees.empty?

    responded_employees = qvt_responses.select(:employee_id).distinct.count
    (responded_employees.to_f / company.employees.count * 100).round(2)
  end

  def completed_qvt_by?(employee)
    qvt_theme_questions = QvtTheme.joins(:qvt_questions).count
    employee_responses = qvt_responses.where(employee: employee).count

    qvt_theme_questions == employee_responses
  end

  def all_questions_answered?(employee)
    total_questions = QvtQuestion.count
    answered_questions = employee.qvt_responses.where(survey: self).count
    total_questions == answered_questions
  end

  def all_themes_completed?(employee)
    QvtTheme.all.all? do |theme|
      theme.completion_status(self, employee) == :completed
    end
  end

  def total_questions
    QvtQuestion.count
  end

  def total_completed_questions(employee)
    qvt_responses.where(employee: employee).count
  end

  def add_participant(employee)
    survey_participants.create!(
      employee: employee,
      invited_at: Time.current
    )
  end

  private

  def company_survey_limit
    if company
      existing_survey = company.surveys.where(survey_type: survey_type).where.not(id: id).exists?
      if existing_survey
        errors.add(:base, "Un sondage de ce type existe déjà pour cette entreprise")
      end
    end
  end
end
