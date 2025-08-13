class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :sleep_at, presence: true
  validate :validate_wake_at, if: :wake_at_changed?
  before_save :calculate_duration

  scope :from_following, ->(follower_id) {
    where("user_id IN (SELECT followed_id FROM follows WHERE follower_id = ?)", follower_id)
  }
  scope :in_a_week, -> { where(created_at: 7.days.ago..Time.current) }

  private

  def validate_wake_at
    if wake_at_was.present? && wake_at != wake_at_was
      errors.add(:wake_at, "cannot be updated once set")
      return
    end

    if wake_at.blank?
      errors.add(:wake_at, "can't be blank")
      return
    end

    if wake_at.present? && sleep_at.present? && wake_at <= sleep_at
      errors.add(:wake_at, "must be after sleep time")
    end
  end

  def calculate_duration
    return unless wake_at_changed? && wake_at.present? && sleep_at.present?

    self.duration = (wake_at - sleep_at).to_i
  end
end
