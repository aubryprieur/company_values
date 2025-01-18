class CreateJoinTableSurveysCompanyValues < ActiveRecord::Migration[7.1]
  def change
    create_join_table :surveys, :company_values do |t|
      t.index [:survey_id, :company_value_id]
      t.index [:company_value_id, :survey_id]
    end
  end
end
