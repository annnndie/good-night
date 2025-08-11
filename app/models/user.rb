class User < ApplicationRecord
  has_many :sleep_records, dependent: :delete_all

  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :delete_all
  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id", dependent: :delete_all

  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  validates :name, presence: true
end
