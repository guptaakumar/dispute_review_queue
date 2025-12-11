class Dispute < ApplicationRecord
  belongs_to :charge
  has_many :case_actions
  has_many :evidence

  # Assumes USD as the currency (required)
  CURRENCY = "USD"

  # Defined states
  enum :status, {
    open: "open",
    needs_evidence: "needs_evidence",
    awaiting_decision: "awaiting_decision",
    won: "won",
    lost: "lost"
  }

  # Money handling (if using money-rails gem)
  # monetizes :amount_cents

  # --- State Transition Methods ---

  def transition_to_needs_evidence(actor)
    return false unless open?
    update!(status: :needs_evidence)
    create_case_action(actor, "transition", "Requested evidence from merchant/user.")
  end

  def transition_to_awaiting_decision(actor)
    return false unless needs_evidence?
    update!(status: :awaiting_decision)
    create_case_action(actor, "transition", "Evidence submitted, awaiting final decision.")
  end

  # 'won' and 'lost' transitions are primarily handled by the WebhookProcessor (Phase 2)
  # for external closure, but they can also be forced by an Admin/Reviewer.

  # Allows 'reopened' from 'won' or 'lost' with justification
  def reopen!(actor, justification)
    return false unless won? || lost?
    update!(status: :needs_evidence) # Or back to 'open'
    create_case_action(actor, "reopened", "Dispute reopened. Justification: #{justification}")
  end

  # Exposes case action creation for controllers/services while keeping the
  # underlying implementation private.
  def record_case_action(actor, action_type, note)
    create_case_action(actor, action_type, note)
  end

  # Converts cents to dollars for display
  def amount_dollars
    self.amount_cents / 100.0
  end

  # Class method helper for summing
  def self.sum_amount_dollars(disputes)
    total_cents =
      if disputes.is_a?(ActiveRecord::Relation)
        disputes.sum(:amount_cents)
      else
        disputes.sum { |d| d.amount_cents.to_i }
      end

    total_cents / 100.0
  end

  private

  def create_case_action(actor, action_type, note)
    case_actions.create!(
      actor: actor,
      action: action_type,
      note: note,
      details: { previous_status: status_before_last_save }
    )
  end
end
