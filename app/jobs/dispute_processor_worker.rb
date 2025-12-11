# app/jobs/dispute_processor_worker.rb
class DisputeProcessorWorker < ApplicationJob
  # Use a dedicated queue for webhooks
  queue_as :webhooks

  def perform(payload)
    @payload = payload
    
    # --- IDEMPOTENCY CHECK 1: Redis Lock (To prevent processing the same payload twice) ---
    # Generate a unique key for this event (assuming a unique event ID is implied by the combination of external IDs and time)
    event_key = "webhook_event:#{payload['dispute_external_id']}:#{payload['event_type']}:#{payload['occurred_at']}"
    
    # Use Redis to acquire a lock (e.g., set key with expiration)
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
    if redis.set(event_key, true, nx: true, ex: 1.day)
      process_dispute_event
    else
      # Duplicate event received - log and exit
      Rails.logger.warn "Skipping duplicate webhook event for dispute ID: #{payload['dispute_external_id']}"
    end
  end

  private

  def process_dispute_event
    charge = find_or_create_charge
    
    # Find the dispute by its external ID
    dispute = Dispute.find_by(external_id: @payload['dispute_external_id'])

    case @payload['event_type']
    when 'dispute.opened' # [cite: 36]
      Dispute.find_or_create_by!(external_id: @payload['dispute_external_id']) do |d|
        d.charge = charge
        d.status = 'open' # Initial state
        d.opened_at = @payload['occurred_at']
        d.amount_cents = (@payload['amount'].to_f * 100).to_i
        d.currency = @payload['currency'] || 'USD'
        d.external_payload = @payload.to_json # Persist raw payload [cite: 34]
      end
    
    when 'dispute.updated' # [cite: 37]
      # --- IDEMPOTENCY CHECK 2: Out-of-Order Check ---
      if dispute && Time.zone.parse(@payload['occurred_at']) > dispute.updated_at
        dispute.update!(
          status: @payload['status'],
          external_payload: @payload.to_json
        )
      end
      
    when 'dispute.closed' # [cite: 38]
      if dispute
        outcome = @payload['outcome'] == 'won' ? 'won' : 'lost'
        # Only transition if the event is newer
        if Time.zone.parse(@payload['occurred_at']) > dispute.updated_at
          dispute.update!(
            status: outcome,
            closed_at: @payload['occurred_at'],
            external_payload: @payload.to_json
          )
        end
      end
    end
  end

  def find_or_create_charge
    Charge.find_or_create_by!(external_id: @payload['charge_external_id']) do |c|
      # Note: Charge data might be incomplete here, but it establishes the link
      c.amount_cents = (@payload['amount'].to_f * 100).to_i
      c.currency = @payload['currency'] || 'USD'
    end
  end
end