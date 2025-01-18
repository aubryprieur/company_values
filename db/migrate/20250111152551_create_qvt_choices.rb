class CreateQvtChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :qvt_choices do |t|
      t.references :qvt_question, null: false, foreign_key: true
      t.string :content, null: false
      t.integer :position

      t.timestamps
    end
  end
end
