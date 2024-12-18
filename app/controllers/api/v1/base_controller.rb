module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_user
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def not_found
        render json: { error: "Resource not found" }, status: :not_found
      end
    end
  end
end
