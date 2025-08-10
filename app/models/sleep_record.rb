class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :sleep_at, presence: true
  validate :wake_at_cannot_be_cleared, if: :wake_at_changed?
  before_save :calculate_duration

  private

  def wake_at_cannot_be_cleared
    errors.add(:wake_at, :blank) if wake_at_was.present? && wake_at.blank?
  end

  def calculate_duration
    return unless wake_at_changed? && wake_at.present? && sleep_at.present?

    self.duration = (wake_at - sleep_at).to_i
  end
end
