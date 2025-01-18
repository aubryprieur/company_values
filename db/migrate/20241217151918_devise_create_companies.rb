class DeviseCreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name,              null: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :companies, :email,                unique: true
    add_index :companies, :reset_password_token, unique: true
  end
end
