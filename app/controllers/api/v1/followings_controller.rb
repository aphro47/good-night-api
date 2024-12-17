module Api
  module V1
    class FollowingsController < BaseController
      before_action :set_user
      before_action :set_target_user, only: [:create, :destroy]

      def create
        if @user.follow(@target_user)
          render json: { message: "Successfully followed user" }, status: :created
        else
          render json: { error: "Unable to follow user" }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.unfollow(@target_user)
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def set_target_user
        @target_user = User.find(params[:target_id])
      end
    end
  end
end
