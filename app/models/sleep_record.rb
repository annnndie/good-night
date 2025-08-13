class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :sleep_at, presence: true
  validate :wake_at_cannot_be_cleared, if: :wake_at_changed?
  before_save :calculate_duration

  scope :from_following, ->(follower_id) {
    where("user_id IN (SELECT followed_id FROM follows WHERE follower_id = ?)", follower_id)
  }
  scope :in_a_week, -> { where(created_at: 7.days.ago..Time.current) }
  
  private

  def wake_at_cannot_be_cleared
    errors.add(:wake_at, :blank) if wake_at_was.present? && wake_at.blank?
  end

  def calculate_duration
    return unless wake_at_changed? && wake_at.present? && sleep_at.present?

    self.duration = (wake_at - sleep_at).to_i
  end
end
