class CreateQvtResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :qvt_responses do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :qvt_question, null: false, foreign_key: true
      t.references :survey, null: false, foreign_key: true
      t.text :text_answer # Pour les questions ouvertes
      t.datetime :completed_at

      t.timestamps
    end

    # Index pour s'assurer qu'un employé ne réponde qu'une fois à une question dans un sondage
    add_index :qvt_responses, [:employee_id, :qvt_question_id, :survey_id], unique: true,
      name: 'index_qvt_responses_on_employee_question_survey'
  end
end
