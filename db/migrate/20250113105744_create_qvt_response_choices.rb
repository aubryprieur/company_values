class CreateQvtResponseChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :qvt_response_choices do |t|
      t.references :qvt_response, null: false, foreign_key: true
      t.references :qvt_choice, null: false, foreign_key: true
      t.integer :position # Pour les questions de type ranking

      t.timestamps
    end

    # Index pour s'assurer qu'un choix n'est pas sélectionné plusieurs fois pour une même réponse
    add_index :qvt_response_choices, [:qvt_response_id, :qvt_choice_id], unique: true,
      name: 'index_qvt_response_choices_on_response_and_choice'
  end
end
