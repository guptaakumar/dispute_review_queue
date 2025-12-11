# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authenticate_user! # All features require sign-in [cite: 46]
  around_action :set_time_zone

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_path, alert: "Please sign in to continue."
    end
  end

  # Helper to enforce admin/reviewer access for admin/triage features
  def authorize_reviewer!
    unless current_user.reviewer?
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  # Helper to enforce admin access for system management features
  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  # Sets the application's time zone based on the signed-in user
  def set_time_zone
    # Use user's time zone or the system default (UTC)
    time_zone = current_user.try(:time_zone) || "UTC"
    Time.use_zone(time_zone) { yield }
  end
end
