# app/models/evidence.rb
class Evidence < ApplicationRecord
  belongs_to :dispute, foreign_key: "dispute_id"

  # Stores metadata in JSONB [cite: 1, 54]
  # For file uploads, metadata could store the local file path/filename [cite: 1, 54]
  # For text notes, metadata could store the full note content
end
