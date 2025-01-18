class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :role, :string, default: 'company'
    add_index :companies, :role
  end
end
