class AddCompletedAtToResponses < ActiveRecord::Migration[8.0]
  def change
    # Ajouter un timestamp pour marquer quand les réponses ont été finalisées
    add_column :responses, :completed_at, :datetime

    # Ajouter un index pour optimiser les requêtes
    add_index :responses, [:employee_id, :company_value_id, :completed_at],
              name: 'index_responses_on_employee_value_and_completion'
  end
end
