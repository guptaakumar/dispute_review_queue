# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
    before_action :authenticate_user! # All roles can view reports

    # GET /reports/daily_volume
    def daily_dispute_volume
      # 1. Resolve date filters using current user's time zone
      start_date = Time.zone.parse(params[:from]) rescue 30.days.ago.beginning_of_day
      end_date = Time.zone.parse(params[:to]) rescue Time.zone.now.end_of_day

      # 2. Query data: disputes opened within the range
      @disputes = Dispute.where(opened_at: start_date.utc..end_date.utc)

      # 3. Group and calculate using user's local time (stored in UTC, convert for grouping)
      @report_data = @disputes.group_by { |d| d.opened_at.in_time_zone(Time.zone).to_date }
                               .map do |date, disputes|
        {
          date: date.to_s,
          count: disputes.count,
          total_disputed_amount: Dispute.sum_amount_dollars(disputes) # Use helper for money math
        }
      end

      # Support JSON response for chart-friendly data
      respond_to do |format|
        format.html # Render HTML table/chart view
        format.json { render json: @report_data }
      end
    end

    # GET /reports/time_to_decision
    def time_to_decision
      # 1. Get closed disputes
      closed_disputes = Dispute.where(status: [ "won", "lost" ]).where.not(closed_at: nil)

      # 2. Calculate duration and group by week
      weekly_durations = closed_disputes.group_by do |d|
        # Group by the Monday of the week (using user's time zone for week boundary)
        d.closed_at.in_time_zone(Time.zone).beginning_of_week(:sunday).to_date
      end

      @report_data = weekly_durations.map do |week_start_date, disputes|
        # Calculate time to decision (in seconds)
        durations = disputes.map { |d| d.closed_at - d.opened_at }.sort

        # Calculate P50 (Median) and P90 percentile
        p50_index = (durations.length * 0.50).ceil - 1
        p90_index = (durations.length * 0.90).ceil - 1

        {
          week: week_start_date.to_s,
          total_count: disputes.count,
          p50_duration_seconds: durations[p50_index],
          p90_duration_seconds: durations[p90_index]
        }
      end

      # Sort by week
      @report_data.sort_by! { |d| d[:week] }
    end
end
