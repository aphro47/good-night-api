module Followings
  class UnfollowService < ApplicationService
    def initialize(follower_id, target_id)
      @follower_id = follower_id
      @target_id = target_id
    end

    def call
      following = Following.find_by(follower_id: @follower_id, followed_id: @target_id)
      raise Api::V1::Errors::NotFoundError.new("Not following this user") unless following

      following.destroy
    end
  end
end
