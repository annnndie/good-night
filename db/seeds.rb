# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating seed data..."

# Create users
users = [
  { name: "Alice Johnson" },
  { name: "Bob Smith" },
  { name: "Charlie Brown" },
  { name: "Diana Prince" },
  { name: "Eve Wilson" }
]

users.each do |user_attrs|
  User.find_or_create_by!(name: user_attrs[:name])
end

puts "Created #{User.count} users"

# Create sleep records for each user
User.all.each do |user|
  puts "Creating sleep records for #{user.name}..."

  # Create more records within the past 7 days for better weekly ranking testing
  (1..7).each do |day|
    days_ago = day

    # Create 1-2 sleep records per day (some users might have multiple naps/records)
    records_for_day = rand(1..2)

    records_for_day.times do |record_num|
      # Main sleep: evening to morning
      if record_num == 0
        sleep_time = days_ago.days.ago.beginning_of_day + rand(21..24).hours + rand(0..59).minutes
        sleep_duration = rand(6..10).hours + rand(0..59).minutes # 6-10 hours sleep
      else
        # Afternoon nap: 1-3 hours
        sleep_time = days_ago.days.ago.beginning_of_day + rand(13..16).hours + rand(0..59).minutes
        sleep_duration = rand(1..3).hours + rand(0..59).minutes # 1-3 hours nap
      end

      wake_time = sleep_time + sleep_duration

      # 90% chance to have complete record for recent data (better for testing)
      wake_at = rand < 0.9 ? wake_time : nil

      sleep_record = user.sleep_records.find_or_create_by(
        sleep_at: sleep_time,
        created_at: sleep_time
      ) do |record|
        record.wake_at = wake_at
      end

      # Ensure duration is calculated if wake_at exists
      if sleep_record.wake_at && !sleep_record.duration
        sleep_record.save!
      end
    end
  end

  # Add a few older records (8-14 days ago) to test the weekly filter
  (8..10).each do |day|
    days_ago = day
    sleep_time = days_ago.days.ago.beginning_of_day + rand(21..24).hours + rand(0..59).minutes
    sleep_duration = rand(6..10).hours + rand(0..59).minutes
    wake_time = sleep_time + sleep_duration

    sleep_record = user.sleep_records.find_or_create_by(
      sleep_at: sleep_time,
      created_at: sleep_time,
      wake_at: wake_time
    )

    sleep_record.save! if sleep_record.wake_at && !sleep_record.duration
  end
end

puts "Created #{SleepRecord.count} sleep records total"

# Create some follow relationships
puts "Creating follow relationships..."

users_list = User.all.to_a

# Alice follows Bob and Charlie
alice = User.find_by(name: "Alice Johnson")
bob = User.find_by(name: "Bob Smith")
charlie = User.find_by(name: "Charlie Brown")
diana = User.find_by(name: "Diana Prince")
eve = User.find_by(name: "Eve Wilson")

follow_relationships = [
  [alice, bob],
  [alice, charlie],
  [bob, alice],
  [bob, diana],
  [charlie, alice],
  [charlie, eve],
  [diana, bob],
  [diana, charlie],
  [eve, alice],
  [eve, diana]
]

follow_relationships.each do |follower, followed|
  next if follower == followed # Skip self-follow

  Follow.find_or_create_by(
    follower: follower,
    followed: followed
  )
end

puts "Created #{Follow.count} follow relationships"

# Display summary
puts "\n=== Seed Data Summary ==="
puts "Users: #{User.count}"
puts "Sleep Records: #{SleepRecord.count}"
puts "- Complete records (with wake_at): #{SleepRecord.where.not(wake_at: nil).count}"
puts "- Incomplete records (no wake_at): #{SleepRecord.where(wake_at: nil).count}"
puts "- Records within past week: #{SleepRecord.where('created_at >= ?', 7.days.ago).count}"
puts "- Records older than a week: #{SleepRecord.where('created_at < ?', 7.days.ago).count}"
puts "Follow relationships: #{Follow.count}"

puts "\nSample user with sleep records:"
sample_user = User.includes(:sleep_records).first
puts "#{sample_user.name} has #{sample_user.sleep_records.count} sleep records"
puts "Following #{sample_user.following.count} users, followed by #{sample_user.followers.count} users"

puts "\nSeed data creation completed!"
