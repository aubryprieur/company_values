class AddTypeToSurveys < ActiveRecord::Migration[8.0]
  def change
    add_column :surveys, :survey_type, :integer, default: 0
    add_index :surveys, [:company_id, :survey_type], unique: true
  end
end
