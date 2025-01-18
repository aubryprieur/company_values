class DeviseCreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name
      t.string :last_name
      t.references :company,        null: false, foreign_key: true
      t.boolean :invitation_accepted, default: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :employees, :email,                unique: true
    add_index :employees, :reset_password_token, unique: true
  end
end
