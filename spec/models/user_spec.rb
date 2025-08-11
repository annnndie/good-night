require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe '#follow' do
    context 'when following a new user' do
      it 'creates a follow relationship' do
        expect { user.follow(other_user) }.to change { user.active_follows.count }.by(1)
        expect(user.following).to include(other_user)
      end
    end

    context 'when trying to follow the same user twice' do
      before { user.follow(other_user) }

      it 'does not create duplicate follow relationship' do
        expect { user.follow(other_user) }.not_to change { user.active_follows.count }
      end
    end
  end

  describe '#unfollow' do
    context 'when unfollowing an existing follow' do
      before { user.follow(other_user) }

      it 'removes the follow relationship' do
        expect { user.unfollow(other_user) }.to change { user.active_follows.count }.by(-1)
        expect(user.following).not_to include(other_user)
      end
    end

    context 'when trying to unfollow a user not being followed' do
      it 'raises an error' do
        expect { user.unfollow(other_user) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#following?' do
    context 'when following the user' do
      before { user.follow(other_user) }

      it 'returns true' do
        expect(user.following?(other_user)).to be true
      end
    end

    context 'when not following the user' do
      it 'returns false' do
        expect(user.following?(other_user)).to be false
      end
    end
  end
end