require 'rails_helper'

RSpec.describe 'Sleep Records API', type: :request do
  let(:user) { create(:user) }

  describe 'GET /sleep_records' do
    context 'with valid user' do
      context 'with sleep records' do
        let!(:sleep_record1) { create(:sleep_record, user: user) }
        let!(:sleep_record2) { create(:sleep_record, user: user) }

        it 'returns sleep records with pagination' do
          get '/api/v1/sleep_records',
              headers: { 'X-User-ID' => user.id },
              as: :json

          expect(response).to have_http_status(:ok)

          sleep_records = json_response['data']['sleep_records']
          expect(sleep_records).to be_an(Array)
          expect(sleep_records.length).to eq(2)
          expect(json_response['data']['current_page']).to eq(1)
          expect(json_response['data']['total_items']).to eq(2)
          expect(json_response['data']['total_pages']).to eq(1)
        end
      end
    end

    context 'without user header' do
      it 'returns unauthorized' do
        get '/api/v1/sleep_records', as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /sleep_records' do
    context 'with valid user' do
      let(:specific_time) { '2025-01-15 23:30:00' }
      it 'creates a new sleep record with specified time' do
        expect {
          post '/api/v1/sleep_records',
               params: {
                 sleep_record: {
                   sleep_at: specific_time
                 }
               },
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
          post '/api/v1/sleep_records', as: :json
        }.not_to change(SleepRecord, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when sleep_at parameter is missing' do
      it 'returns parameter missing error' do
        post '/api/v1/sleep_records',
             headers: { 'X-User-ID' => user.id },
             as: :json

        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to eq('Parameter is required')
      end
    end

    context 'when validation fails' do
      let(:invalid_record) { SleepRecord.create }
      it 'returns validation errors' do
        allow_any_instance_of(User).to receive_message_chain(:sleep_records, :create!)
          .and_raise(ActiveRecord::RecordInvalid.new(invalid_record))

        post '/api/v1/sleep_records',
             params: { sleep_at: '2025-01-15 23:30:00' },
             headers: { 'X-User-ID' => user.id },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_an(Array)
      end
    end
  end

  describe 'PATCH /sleep_records/:id' do
    let!(:sleep_record) { create(:sleep_record, user: user) }
    let(:wake_time) { '2025-01-16 07:30:00' }

    context 'with valid user and record' do
      it 'updates wake_at time and returns complete record' do
        patch "/api/v1/sleep_records/#{sleep_record.id}",
              params: {
                sleep_record: {
                  wake_at: wake_time
                }
              },
              headers: { 'X-User-ID' => user.id },
              as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['sleep_record']).to have_key('id')
        expect(json_response['data']['sleep_record']).to have_key('sleep_at')
        expect(json_response['data']['sleep_record']).to have_key('wake_at')
        expect(json_response['data']['sleep_record']).to have_key('duration')

        sleep_record.reload
        expect(sleep_record.wake_at).to be_present
        expect(sleep_record.duration).to be_present
      end
    end

    context 'without wake_at parameter' do
      it 'returns parameter missing error' do
        patch "/api/v1/sleep_records/#{sleep_record.id}",
              params: { sleep_record: {} },
              headers: { 'X-User-ID' => user.id },
              as: :json

        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to eq('Parameter is required')
      end
    end

    context 'with non-existent record' do
      it 'returns not found error' do
        patch '/api/v1/sleep_records/999999',
              params: {
                sleep_record: {
                  wake_at: wake_time
                }
              },
              headers: { 'X-User-ID' => user.id },
              as: :json

        expect(response).to have_http_status(:not_found)
        expect(json_response['errors']).to eq('Sleep record not found')
      end
    end

    context 'without user header' do
      it 'returns unauthorized' do
        patch "/api/v1/sleep_records/#{sleep_record.id}",
              params: {
                sleep_record: {
                  wake_at: wake_time
                }
              },
              as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  private

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
