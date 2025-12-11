class CaseAction < ApplicationRecord
  belongs_to :dispute, foreign_key: 'dispute_id'
  belongs_to :actor, class_name: 'User', foreign_key: 'user_id'
end
