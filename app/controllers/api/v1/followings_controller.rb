module Api
  module V1
    class FollowingsController < BaseController
      # POST /api/v1/users/:id/follow/:target_id
      # Follow another user
      # @param [Integer] id User ID
      # @param [Integer] target_id Target user ID to follow
      # @return [Hash] Success message
      def create
        following = Followings::FollowService.call(params[:id], params[:target_id])
        render json: following, status: :created
      rescue Api::V1::Errors::BaseError => e
        render json: { error: e.message }, status: e.status
      end

      # DELETE /api/v1/users/:id/unfollow/:target_id
      # Unfollow a user
      # @param [Integer] id User ID
      # @param [Integer] target_id Target user ID to unfollow
      # @return [nil] No content
      def destroy
        Followings::UnfollowService.call(params[:id], params[:target_id])
        head :no_content
      rescue Api::V1::Errors::BaseError => e
        render json: { error: e.message }, status: e.status
      end
    end
  end
end
