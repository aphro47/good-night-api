require "test_helper"

module Api
  module V1
    class FollowingsControllerTest < ActionDispatch::IntegrationTest
      def setup
        @user = User.create!(name: "Test User")
        @target_user = User.create!(name: "Target User")
      end

      test "should follow user" do
        assert_difference("Following.count") do
          post follow_api_v1_user_path(@user, target_id: @target_user.id)
          assert_response :created
        end

        assert @user.following?(@target_user)
      end

      test "should unfollow user" do
        @user.follow(@target_user)

        assert_difference("Following.count", -1) do
          delete unfollow_api_v1_user_path(@user, target_id: @target_user.id)
          assert_response :no_content
        end

        assert_not @user.following?(@target_user)
      end
    end
  end
end
