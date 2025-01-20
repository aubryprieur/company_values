class Employee < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :company
  has_many :responses, dependent: :destroy
  has_many :custom_values, dependent: :destroy
  has_many :qvt_responses, dependent: :destroy
  has_many :survey_participants
  has_many :participating_surveys, through: :survey_participants, source: :survey

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  before_create :generate_invitation_token

  def generate_invitation_token
    self.invitation_token = SecureRandom.hex(20)
    self.invitation_sent_at = Time.current
  end

  def invitation_expired?
    invitation_sent_at < 24.hours.ago
  end

  def accept_invitation!
    update(invitation_accepted_at: Time.current, invitation_token: nil)
  end

  def invitation_accepted?
    invitation_accepted_at.present?
  end

  def invited_to_survey?(survey)
    survey_participants.exists?(survey: survey)
  end
end
