class CreateSurveys < ActiveRecord::Migration[8.0]
  def change
    create_table :surveys do |t|
      t.string :title
      t.datetime :end_date
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
