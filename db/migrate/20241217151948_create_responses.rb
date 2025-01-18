class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.integer :rating
      t.text :comment
      t.references :employee, null: false, foreign_key: true
      t.references :company_value, null: false, foreign_key: true

      t.timestamps
    end
  end
end
