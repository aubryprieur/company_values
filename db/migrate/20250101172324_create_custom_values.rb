class CreateCustomValues < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_values do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.references :employee, foreign_key: true
      t.references :survey, foreign_key: true
      t.timestamps
    end
  end
end
