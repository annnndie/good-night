require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'validates presence of sleep_at' do
      sleep_record = build(:sleep_record, user: user, sleep_at: nil)
      expect(sleep_record).not_to be_valid
      expect(sleep_record.errors[:sleep_at]).to include("can't be blank")
    end

    context 'when wake_at is already set' do
      let(:sleep_record) { create(:sleep_record, user: user, wake_at: '2025-01-16 07:30:00') }

      it 'prevents updating wake_at once it has been set' do
        sleep_record.wake_at = '2025-01-16 08:00:00'

        expect(sleep_record).not_to be_valid
        expect(sleep_record.errors[:wake_at]).to include("cannot be updated once set")
      end

      it 'prevents clearing wake_at once it has been set' do
        sleep_record.wake_at = nil

        expect(sleep_record).not_to be_valid
        expect(sleep_record.errors[:wake_at]).to include("cannot be updated once set")
      end

      it 'allows saving without changing wake_at' do
        expect(sleep_record.save).to be true
      end
    end

    context 'when updating wake_at' do
      it 'allows creating record without setting wake_at initially' do
        sleep_record = build(:sleep_record, user: user)

        expect(sleep_record).to be_valid
        expect(sleep_record.wake_at).to be_nil
      end

      it 'allows first-time setting of valid wake_at' do
        sleep_record = create(:sleep_record, user: user, sleep_at: '2025-01-16 00:30:00')
        sleep_record.wake_at = '2025-01-16 08:30:00'

        expect(sleep_record).to be_valid
      end
    end

    context 'when wake_at is not after sleep_at' do
      let(:sleep_at) { Time.parse('2025-01-16 00:30:00') }

      it 'prevents wake_at from being equal to sleep_at' do
        sleep_record = build(:sleep_record, user: user, sleep_at: sleep_at, wake_at: sleep_at)

        expect(sleep_record).not_to be_valid
        expect(sleep_record.errors[:wake_at]).to include("must be after sleep time")
      end

      it 'prevents wake_at from being before sleep_at' do
        sleep_record = build(:sleep_record, user: user, sleep_at: sleep_at, wake_at: sleep_at - 1.hour)

        expect(sleep_record).not_to be_valid
        expect(sleep_record.errors[:wake_at]).to include("must be after sleep time")
      end

      it 'allows wake_at to be after sleep_at' do
        sleep_record = build(:sleep_record, user: user, sleep_at: sleep_at, wake_at: sleep_at + 8.hours)

        expect(sleep_record).to be_valid
      end
    end
  end

  describe 'duration calculation' do
    let(:sleep_record) { sleep_record = create(:sleep_record, user: user) }

    context 'when creating a record without wake_at' do
      it 'does not calculate duration' do
        expect(sleep_record.duration).to be_nil
      end
    end

    context 'when updating wake_at' do
      it 'calculates duration' do
        sleep_record.update!(wake_at: '2025-01-16 06:30:00')

        expect(sleep_record.duration).to eq(25200) # 7 hours = 25200 seconds
      end
    end
  end

  describe 'scopes' do
    let(:follower) { create(:user) }
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }
    let(:unfollowed_user) { create(:user) }

    before do
      follower.follow(followed_user1)
      follower.follow(followed_user2)
    end

    describe '.from_following' do
      let!(:followed_record1) { create(:sleep_record, user: followed_user1) }
      let!(:followed_record2) { create(:sleep_record, user: followed_user2) }
      let!(:unfollowed_record) { create(:sleep_record, user: unfollowed_user) }

      it 'returns records from followed users only' do
        records = SleepRecord.from_following(follower.id)

        expect(records).to include(followed_record1, followed_record2)
        expect(records).not_to include(unfollowed_record)
      end

      it 'returns empty result when user follows nobody' do
        lonely_user = create(:user)
        records = SleepRecord.from_following(lonely_user.id)

        expect(records).to be_empty
      end
    end
  end
end
