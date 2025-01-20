class CreateSurveyParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_participants do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.datetime :invited_at
      t.datetime :responded_at

      t.timestamps
    end

    add_index :survey_participants, [:survey_id, :employee_id], unique: true
  end
end
