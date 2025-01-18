class QvtResponse < ApplicationRecord
  belongs_to :employee
  belongs_to :qvt_question
  belongs_to :survey
  has_many :qvt_response_choices, dependent: :destroy
  has_many :qvt_choices, through: :qvt_response_choices

  validates :qvt_question_id, uniqueness: { scope: [:employee_id, :survey_id] }

    # Ne valider que si la réponse est complétée
    validate :validate_response_type, if: :completed?

  def completed?
    completed_at.present?
  end

  private

  def validate_response_type
    case qvt_question.question_type
    when 'single_choice'
      validate_single_choice
    when 'multiple_choice'
      validate_multiple_choice
    when 'open'
      validate_open_answer
    when 'ranking'
      validate_ranking
    end
  end

  def validate_single_choice
    if qvt_response_choices.size != 1
      errors.add(:base, "Une seule réponse doit être sélectionnée")
    end
  end

  def validate_multiple_choice
    if qvt_response_choices.empty?
      errors.add(:base, "Au moins une réponse doit être sélectionnée")
    end
  end

  def validate_open_answer
    if text_answer.blank?
      errors.add(:text_answer, "ne peut pas être vide")
    end
  end

  def validate_ranking
    return unless qvt_response_choices.loaded? || qvt_response_choices.any?

    choices_count = qvt_question.qvt_choices.count
    responses_count = qvt_response_choices.count

    if responses_count != choices_count
      errors.add(:base, "Tous les choix doivent être classés")
      return
    end

    positions = qvt_response_choices.pluck(:position)
    expected_positions = (0...choices_count).to_a

    if positions.sort != expected_positions
      errors.add(:base, "Le classement doit être continu et commencer à 0")
    end
  end
end
