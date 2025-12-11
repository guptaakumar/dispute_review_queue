# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :case_actions, foreign_key: :actor_id

  # enum role: { read_only: 'read_only', reviewer: 'reviewer', admin: 'admin' }

  # Default values
  after_initialize :set_defaults

  def set_defaults
    self.role ||= :read_only
    self.time_zone ||= 'UTC' # Sensible default [cite: 59]
  end

  # RBAC helper methods
  def admin?
    role == 'admin' # [cite: 48]
  end

  def reviewer?
    admin? || role == 'reviewer' # [cite: 49]
  end
  
  # read_only? is implicit
end
