# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :case_actions, foreign_key: :actor_id

  enum :role, { read_only: 'read_only', reviewer: 'reviewer', admin: 'admin' }

  # Default values
  after_initialize :set_defaults

  # Returns the configured default password for a given role, falling back to a
  # shared default and finally "password" for local/dev setups.
  def self.default_password_for(role)
    defaults = Rails.application.credentials.dig(:default_users)

    case defaults
    when Hash
      defaults = defaults.with_indifferent_access
      defaults[role] || defaults[:all] || defaults[:password] || "password"
    when String
      defaults.presence || "password"
    else
      "password"
    end
  end

  def set_defaults
    self.role ||= :read_only
    self.time_zone ||= "UTC" # Sensible default [cite: 59]
  end

  # RBAC helper methods
  def admin?
    role == "admin" # [cite: 48]
  end

  def reviewer?
    admin? || role == "reviewer" # [cite: 49]
  end

  # read_only? is implicit
end
