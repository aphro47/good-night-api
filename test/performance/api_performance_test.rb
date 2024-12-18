require "test_helper"
require "benchmark/ips"
require "ruby-prof"

class ApiPerformanceTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.first || create_test_data
    @target_user = User.second
    @sleep_record = @user.sleep_records.first
  end

  def create_test_data
    # Create test users if no data exists
    user = User.create!(name: "Test User")
    target = User.create!(name: "Target User")

    # Create some sleep records
    user.sleep_records.create!(
      clock_in_at: 1.day.ago,
      clock_out_at: 1.day.ago + 8.hours
    )

    user
  end

  def test_following_records_performance
    puts "\nTesting following_records performance..."

    # Profile memory and CPU
    profile = RubyProf::Profile.new
    result = profile.profile do
      10.times do
        get sleep_records_following_api_v1_user_path(@user)
        assert_response :success
      end
    end

    # Print CPU time report
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, min_percent: 2)

    # Benchmark speed
    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report("following_records") do
        get sleep_records_following_api_v1_user_path(@user)
      end

      x.compare!
    end
  end

  def test_clock_in_performance
    puts "\nTesting clock_in performance..."

    profile = RubyProf::Profile.new
    result = profile.profile do
      10.times do
        post sleep_records_clock_in_api_v1_user_path(@user)
        assert_response :success
      end
    end

    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, min_percent: 2)

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report("clock_in") do
        post sleep_records_clock_in_api_v1_user_path(@user)
      end

      x.compare!
    end
  end

  def test_follow_unfollow_performance
    puts "\nTesting follow/unfollow performance..."

    profile = RubyProf::Profile.new
    result = profile.profile do
      10.times do
        post follow_api_v1_user_path(@user, target_id: @target_user.id)
        assert_response :success
        delete unfollow_api_v1_user_path(@user, target_id: @target_user.id)
        assert_response :success
      end
    end

    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, min_percent: 2)

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report("follow/unfollow") do
        post follow_api_v1_user_path(@user, target_id: @target_user.id)
        delete unfollow_api_v1_user_path(@user, target_id: @target_user.id)
      end

      x.compare!
    end
  end
end
