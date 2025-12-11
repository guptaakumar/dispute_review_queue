# app/controllers/disputes_controller.rb
require 'fileutils'

class DisputesController < ApplicationController
  # Gate access: Reviewer and Admin can triage [cite: 1, 49]
  before_action :authorize_reviewer!, only: [:update] 

  def index
    # Only Admin and Reviewer focus on the active queue
    if current_user.reviewer?
      # Reviewers/Admins primarily focus on OPEN and NEEDS_EVIDENCE cases
      @disputes = Dispute.where(status: ['open', 'needs_evidence', 'awaiting_decision'])
                         .includes(:charge)
                         .order(opened_at: :desc)
    else # Read-Only users and others can view all historical data
      @disputes = Dispute.all
                         .includes(:charge)
                         .order(opened_at: :desc)
    end
  end

  # Case details view
  def show
    @dispute = Dispute.find(params[:id])
    @case_actions = @dispute.case_actions.order(created_at: :desc)
    @evidence = @dispute.evidence
  end

  # Endpoint for handling status transitions and case actions
  def update
    @dispute = Dispute.find(params[:id])

    # 1. Handle Status Transition requests
    if params[:status_transition].present?
      transition = params[:status_transition]
      justification = params[:justification]

      # Use the methods defined in the Dispute model
      if transition == 'needs_evidence'
        @dispute.transition_to_needs_evidence(current_user)
      elsif transition == 'awaiting_decision'
        @dispute.transition_to_awaiting_decision(current_user)
      elsif transition == 'reopened' && justification.present?
        @dispute.reopen!(current_user, justification)
      end
    # 2. Handle Evidence Attachment (Note/File)
    elsif params[:evidence].present?
      # Evidence form posts top-level params (kind, note, file_path)
      evidence_params = params.permit(:kind, :note, :file_path)
      metadata = {}
      metadata[:note] = evidence_params[:note] if evidence_params[:note].present?
      if evidence_params[:file_path].present?
        file_param = evidence_params[:file_path]

        if file_param.respond_to?(:original_filename) && file_param.respond_to?(:read)
          uploads_dir = Rails.root.join('public', 'uploads')
          FileUtils.mkdir_p(uploads_dir)

          # Use timestamp prefix to avoid collisions and keep name readable.
          safe_name = "#{Time.zone.now.to_i}_#{file_param.original_filename}"
          dest_path = uploads_dir.join(safe_name)

          File.open(dest_path, 'wb') { |f| f.write(file_param.read) }
          metadata[:file_path] = safe_name
        else
          # Fallback for non-upload string references
          metadata[:file_path] = file_param.to_s
        end
      end

      @dispute.evidence.create!(
        kind: evidence_params[:kind],
        metadata: metadata
      )
      @dispute.record_case_action(
        current_user,
        'evidence_attached',
        "New evidence of kind '#{evidence_params[:kind]}' added."
      )
    end

    redirect_to @dispute, notice: "Dispute updated successfully."
  end
end
