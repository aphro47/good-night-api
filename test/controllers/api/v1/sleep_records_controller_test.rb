require "test_helper"

module Api
  module V1
    class SleepRecordsControllerTest < ActionDispatch::IntegrationTest
      def setup
        @user = User.create!(name: "Test User")
        @friend = User.create!(name: "Friend")
        @user.follow(@friend)

        @friend.sleep_records.create!(
          clock_in_at: 1.day.ago,
          clock_out_at: 1.day.ago + 8.hours
        )
      end

      test "should create sleep record on clock in" do
        assert_difference("SleepRecord.count") do
          post sleep_records_clock_in_api_v1_user_path(@user)
          assert_response :created
        end

        json_response = JSON.parse(response.body)
        assert_equal @user.sleep_records.count, json_response.length
      end

      test "should update sleep record on clock out" do
        sleep_record = @user.sleep_records.create!(clock_in_at: 8.hours.ago)

        post sleep_record_clock_out_api_v1_user_path(@user, sleep_record_id: sleep_record.id)
        assert_response :success

        sleep_record.reload
        assert_not_nil sleep_record.clock_out_at
        assert_not_nil sleep_record.duration_minutes
      end

      test "should get following records" do
        get sleep_records_following_api_v1_user_path(@user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal 1, json_response.length
        assert_equal @friend.id, json_response.first["user"]["id"]
      end
    end
  end
end
