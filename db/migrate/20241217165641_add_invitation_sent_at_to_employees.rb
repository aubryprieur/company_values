class AddInvitationSentAtToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :invitation_sent_at, :datetime
  end
end
