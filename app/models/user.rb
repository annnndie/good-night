class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  validates :name, presence: true
end
