class SleepRecordsController < ApplicationController
  def index; end

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
    params.require(:sleep_record).permit(:sleep_at)
  end

  def update_params
    params.require(:sleep_record).permit(:wake_at)
  end
end
