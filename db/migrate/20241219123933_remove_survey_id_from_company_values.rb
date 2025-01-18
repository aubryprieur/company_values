class RemoveSurveyIdFromCompanyValues < ActiveRecord::Migration[7.1]
  def change
    remove_reference :company_values, :survey, foreign_key: true
  end
end
