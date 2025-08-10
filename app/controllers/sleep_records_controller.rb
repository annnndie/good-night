class SleepRecordsController < ApplicationController
  def index; end

  def create
    sleep_record = current_user.sleep_records.create!(
      sleep_at: create_params
    )

    render json: {
      data: {
        sleep_record: {
          id: sleep_record.id,
          sleep_at: sleep_record.sleep_at
        }
      }
    }, status: :created
  rescue ActionController::ParameterMissing
    render json: {
      errors: "sleep_at parameter is required"
    }, status: :bad_request
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      errors: e.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def update; end

  private

  def create_params
    params.require(:sleep_at)
  end
end
