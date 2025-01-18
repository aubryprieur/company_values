class Response < ApplicationRecord
  belongs_to :employee
  belongs_to :company_value

  validates :rating, presence: true, inclusion: { in: 1..10 }
  validates :company_value_id, uniqueness: { scope: :employee_id, message: "a déjà été évalué" },
    unless: :completing_survey

  attr_accessor :completing_survey

  def completed?
    completed_at.present?
  end

  def mark_as_completed!
    self.completing_survey = true
    update(completed_at: Time.current)
  end

  def can_be_modified?
    !completed?
  end
end
