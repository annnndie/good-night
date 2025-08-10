FactoryBot.define do
  factory :sleep_record do
    association :user
    sleep_at { '2025-01-15 23:30:00' }
    wake_at { nil }
    duration { nil }
  end

  trait :with_wake_time do
    wake_at { '2025-01-16 07:30:00' }
  end
end
