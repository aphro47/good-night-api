# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Clear existing data
puts "Clearing existing data..."
Following.delete_all
SleepRecord.delete_all
User.delete_all

# Create users
puts "Creating users..."
users = []
1000.times do |i|
  users << User.create!(
    name: Faker::Name.unique.name
  )
  print "." if i % 100 == 0
end
puts "\nCreated #{users.count} users"

# Create followings (each user follows ~50 random users)
puts "\nCreating followings..."
users.each_with_index do |user, i|
  follow_count = rand(40..60)
  (users - [ user ]).sample(follow_count).each do |target_user|
    user.follow(target_user)
  end
  print "." if i % 100 == 0
end
puts "\nCreated #{Following.count} followings"

# Create sleep records (last 30 days of records)
puts "\nCreating sleep records..."
sleep_record_count = 0
users.each_with_index do |user, i|
  # Each user has 20-30 sleep records in the last month
  record_count = rand(20..30)
  record_count.times do
    # Random date in the last 30 days
    start_time = rand(1..30).days.ago

    # Sleep duration between 4 and 12 hours
    duration_hours = rand(4..12)

    SleepRecord.create!(
      user: user,
      clock_in_at: start_time,
      clock_out_at: start_time + duration_hours.hours
    )
    sleep_record_count += 1
  end
  print "." if i % 100 == 0
end
puts "\nCreated #{sleep_record_count} sleep records"
