class Api::V1::SleepRecordsController < ApplicationController
  include DatetimeValidation

  def index
    @pagy, sleep_records = pagy(current_user.sleep_records.order(created_at: :desc))

    render_json_with_page(:ok, {
      sleep_records: sleep_records.map do |record|
        {
          id: record.id,
          sleep_at: record.sleep_at,
          wake_at: record.wake_at,
          duration: record.duration
        }
      end
    })
  end

  def following
    record_query = SleepRecord.from_following(current_user.id)
                              .in_a_week
                              .where.not(duration: nil)
                              .includes(:user)
                              .order(duration: :desc)

    @pagy, sleep_records = pagy(record_query)

    render_json_with_page(:ok, {
      sleep_records: sleep_records.map do |record|
        {
          id: record.id,
          user_name: record.user.name,
          sleep_at: record.sleep_at,
          wake_at: record.wake_at,
          duration: record.duration
        }
      end
    })
  end

  def create
    sleep_record = current_user.sleep_records.create!(create_params)

    render_json(:created, {
      sleep_record: {
        id: sleep_record.id,
        sleep_at: sleep_record.sleep_at
      }
    })
  end

  def update
    sleep_record = current_user.sleep_records.find(params[:id])
    sleep_record.update!(update_params)

    render_json(:ok, {
      sleep_record: {
        id: sleep_record.id,
        sleep_at: sleep_record.sleep_at,
        wake_at: sleep_record.wake_at,
        duration: sleep_record.duration
      }
    })
  end

  private

  def create_params
    params.require(:sleep_record).permit(:sleep_at).tap do |permitted|
      validate_datetime_params(permitted)
    end
  end

  def update_params
    params.require(:sleep_record).permit(:wake_at).tap do |permitted|
      validate_datetime_params(permitted)
    end
  end
end
