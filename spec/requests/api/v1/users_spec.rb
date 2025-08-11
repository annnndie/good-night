require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, name: 'Other User') }

  describe 'POST /api/v1/users/follow' do
    context 'with valid user and followed_id' do
      it 'creates a new follow relationship' do
        expect {
          post '/api/v1/users/follow',
               params: { followed_id: other_user.id },
               headers: { 'X-User-ID' => user.id },
               as: :json
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['follow']).to have_key('follower_id')
        expect(json_response['data']['follow']).to have_key('followed_id')
        expect(json_response['data']['follow']['follower_id']).to eq(user.id)
        expect(json_response['data']['follow']['followed_id']).to eq(other_user.id)
      end
    end

    context 'when trying to follow yourself' do
      it 'returns validation error' do
        expect {
          post '/api/v1/users/follow',
               params: { followed_id: user.id },
               headers: { 'X-User-ID' => user.id },
               as: :json
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include('Followed cannot follow yourself')
      end
    end

    context 'with non-existent user' do
      it 'returns not found error' do
        post '/api/v1/users/follow',
             params: { followed_id: 999999 },
             headers: { 'X-User-ID' => user.id },
             as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/users/unfollow' do
    context 'when following the user' do
      before { user.follow(other_user) }

      it 'unfollows the user successfully' do
        expect {
          post '/api/v1/users/unfollow', params: { followed_id: other_user.id },
                 headers: { 'X-User-ID' => user.id },
                 as: :json
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not following the user' do
      it 'returns not found error' do
        expect {
          post '/api/v1/users/unfollow', params: { followed_id: other_user.id },
                 headers: { 'X-User-ID' => user.id },
                 as: :json
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:not_found)
        expect(json_response['errors']).to include('Follow not found')
      end
    end
  end

  private

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
