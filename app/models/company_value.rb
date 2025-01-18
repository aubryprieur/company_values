class CompanyValue < ApplicationRecord
  belongs_to :value_category, optional: true
  has_and_belongs_to_many :surveys
  has_many :responses, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end
