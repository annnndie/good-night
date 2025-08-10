require 'rails_helper'

RSpec.describe 'Sleep Records API', type: :request do
  let(:user) { create(:user) }

  describe 'POST /sleep_records' do
    context 'with valid user' do
      let(:specific_time) { '2025-01-15 23:30:00' }
      it 'creates a new sleep record with specified time' do
        expect {
          post '/sleep_records',
               params: { sleep_at: specific_time },
               headers: { 'X-User-ID' => user.id },
               as: :json
        }.to change(SleepRecord, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['sleep_record']).to have_key('id')
        expect(json_response['data']['sleep_record']).to have_key('sleep_at')

        sleep_record = SleepRecord.last
        expect(sleep_record.user_id).to eq(user.id)
        expect(sleep_record.sleep_at).to be_present
        expect(sleep_record.wake_at).to be_nil
      end
    end

    context 'without user header' do
      it 'returns unauthorized' do
        expect {
          post '/sleep_records', as: :json
        }.not_to change(SleepRecord, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when sleep_at parameter is missing' do
      it 'returns parameter missing error' do
        post '/sleep_records',
             headers: { 'X-User-ID' => user.id },
             as: :json

        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to eq('sleep_at parameter is required')
      end
    end

    context 'when validation fails' do
      let(:invalid_record) { SleepRecord.create }
      it 'returns validation errors' do
        allow_any_instance_of(User).to receive_message_chain(:sleep_records, :create!)
          .and_raise(ActiveRecord::RecordInvalid.new(invalid_record))

        post '/sleep_records',
             params: { sleep_at: '2025-01-15 23:30:00' },
             headers: { 'X-User-ID' => user.id },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_an(Array)
      end
    end
  end

  private

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
