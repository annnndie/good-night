class User < ApplicationRecord
  has_many :sleep_records, dependent: :delete_all

  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :delete_all
  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id", dependent: :delete_all

  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  validates :name, presence: true

  def follow(user)
    active_follows.find_or_create_by!(followed: user)
  end

  def unfollow(user)
    follow_record = active_follows.find_by!(followed: user)
    follow_record.destroy
  end

  def following?(user)
    following.include?(user)
  end
end
