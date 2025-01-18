class AddValueCategoryToCompanyValues < ActiveRecord::Migration[7.1]
  def change
    add_reference :company_values, :value_category, null: true, foreign_key: true
  end
end
