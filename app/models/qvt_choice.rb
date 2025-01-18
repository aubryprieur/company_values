class QvtChoice < ApplicationRecord
  belongs_to :qvt_question
  validates :content, presence: true
end
