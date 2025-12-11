# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
    # Skip authentication for the public webhook endpoint
    skip_before_action :authenticate_user!
    # Skip CSRF token verification for API endpoint
    skip_before_action :verify_authenticity_token

    def disputes
      payload = JSON.parse(request.body.read)
      events = normalize_events(payload)

      # 1. Basic Schema Validation (minimal check)
      if events.blank? || events.any? { |event| !valid_dispute_payload?(event) }
        return render json: { error: "Invalid payload schema" }, status: :bad_request
      end

      # 2. Enqueue each event as its own job
      events.each { |event| DisputeProcessorWorker.perform_later(event) }

      # 3. Return accepted status quickly
      render json: { message: "Event received and queued" }, status: :accepted # 202 Accepted
    rescue JSON::ParserError
      render json: { error: "Invalid JSON format" }, status: :bad_request
    end

    private

    def normalize_events(payload)
      return payload if payload.is_a?(Array)
      return [ payload ] if payload.is_a?(Hash)
      nil
    end

    def valid_dispute_payload?(payload)
      # Check for core required fields
      payload.is_a?(Hash) &&
      payload["charge_external_id"].present? &&
      payload["dispute_external_id"].present? &&
      payload["amount"].present? &&
      payload["status"].present? &&
      payload["event_type"].present? &&
      payload["occurred_at"].present?
    end
end
