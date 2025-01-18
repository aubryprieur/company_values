class CreateCompanyValues < ActiveRecord::Migration[8.0]
  def change
    create_table :company_values do |t|
      t.string :name
      t.text :description
      t.references :survey, null: false, foreign_key: true

      t.timestamps
    end
  end
end
