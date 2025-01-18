# app/models/custom_value.rb
class CustomValue < ApplicationRecord
  belongs_to :employee
  belongs_to :survey
  validates :name, :description, presence: true
  validates_uniqueness_of :name, scope: [:employee_id, :survey_id]
  validate :max_three_values_per_employee

  private

  def max_three_values_per_employee
    if employee.custom_values.where(survey: survey).count >= 3
      errors.add(:base, "Maximum 3 valeurs personnalisées autorisées")
    end
  end
end
