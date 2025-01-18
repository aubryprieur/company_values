class ValueCategory < ApplicationRecord
  has_many :company_values, dependent: :nullify
  validates :name, presence: true
end
