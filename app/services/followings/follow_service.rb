module Followings
  class FollowService < ApplicationService
    def initialize(follower_id, target_id)
      @follower_id = follower_id
      @target_id = target_id
    end

    def call
      validate_users!
      create_following
      { message: "Successfully followed the user" }
    end

    private

    def validate_users!
      raise Api::V1::Errors::ValidationError.new("Can't follow yourself") if @follower_id == @target_id

      [ @follower_id, @target_id ].each do |id|
        User.find(id)
      rescue ActiveRecord::RecordNotFound
        raise Api::V1::Errors::NotFoundError.new("User not found")
      end
    end

    def create_following
      Following.create!(
        follower_id: @follower_id,
        followed_id: @target_id
      )
    rescue ActiveRecord::RecordNotUnique
      raise Api::V1::Errors::ValidationError.new("Already following this user")
    end
  end
end
