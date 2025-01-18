class Company < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[super_admin company].freeze

  has_many :employees, dependent: :destroy
  has_many :surveys, dependent: :destroy

  validates :role, inclusion: { in: ROLES }
  validates :name, presence: true

  def super_admin?
    role == 'super_admin'
  end

  ORGANIZATION_TYPES = ['entreprise_privee', 'association', 'secteur_public'].freeze

  validates :organization_type, presence: true, inclusion: { in: ORGANIZATION_TYPES }

  def self.organization_type_options
    {
      'Entreprise privée' => 'entreprise_privee',
      'Association' => 'association',
      'Secteur public' => 'secteur_public'
    }
  end

end
