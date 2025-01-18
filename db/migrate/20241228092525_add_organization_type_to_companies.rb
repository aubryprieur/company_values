class AddOrganizationTypeToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :organization_type, :string
  end
end
