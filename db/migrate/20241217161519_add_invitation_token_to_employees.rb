class AddInvitationTokenToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :invitation_token, :string
    add_column :employees, :invitation_accepted_at, :datetime
  end
end
