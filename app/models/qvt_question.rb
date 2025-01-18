class QvtQuestion < ApplicationRecord
  belongs_to :qvt_theme
  has_many :qvt_choices, dependent: :destroy
  has_many :qvt_responses, dependent: :destroy

  enum :question_type, {
    single_choice: 0,    # Question à choix unique
    multiple_choice: 1,  # Question à choix multiples
    open: 2,            # Question ouverte
    ranking: 3          # Question avec classement
  }

  validates :content, presence: true
  validates :question_type, presence: true

  accepts_nested_attributes_for :qvt_choices, allow_destroy: true, reject_if: :all_blank

  def response_stats(survey)
    case question_type
    when 'single_choice', 'multiple_choice'
      choice_stats(survey)
    when 'ranking'
      ranking_stats(survey)
    when 'open'
      text_stats(survey)
    end
  end

  private

  def choice_stats(survey)
    responses = qvt_responses.where(survey: survey)
    total_responses = responses.count.to_f

    qvt_choices.map do |choice|
      count = QvtResponseChoice.joins(:qvt_response)
        .where(qvt_responses: { survey_id: survey.id }, qvt_choice: choice)
        .count

      {
        choice: choice,
        count: count,
        percentage: total_responses > 0 ? ((count / total_responses) * 100).round(2) : 0
      }
    end
  end

  def ranking_stats(survey)
    responses = qvt_responses.where(survey: survey)
    total_responses = responses.count.to_f

    qvt_choices.map do |choice|
      positions = QvtResponseChoice.joins(:qvt_response)
        .where(qvt_responses: { survey_id: survey.id }, qvt_choice: choice)
        .pluck(:position)

      avg_position = positions.any? ? (positions.sum.to_f / positions.count).round(2) : nil

      {
        choice: choice,
        average_position: avg_position,
        responses_count: positions.count
      }
    end.sort_by { |stat| stat[:average_position] || Float::INFINITY }
  end

  def text_stats(survey)
    qvt_responses.where(survey: survey).pluck(:text_answer).compact
  end
end
