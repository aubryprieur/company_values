class CreateValueCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :value_categories do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
