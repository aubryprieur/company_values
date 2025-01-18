class CreateQvtQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :qvt_questions do |t|
      t.references :qvt_theme, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :question_type, null: false, default: 0
      t.boolean :required, default: true
      t.integer :position

      t.timestamps
    end
  end
end
