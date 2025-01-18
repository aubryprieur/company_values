class QvtResponseChoice < ApplicationRecord
  belongs_to :qvt_response
  belongs_to :qvt_choice

  validates :qvt_choice_id, presence: true
  validates :position, presence: true, if: -> { qvt_response&.qvt_question&.ranking? }

end
