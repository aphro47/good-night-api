module Api
  module V1
    class SleepRecordsController < BaseController
      include Pagy::Backend
      before_action :set_user
      before_action :set_sleep_record, only: [ :clock_out ]

      # POST /api/v1/users/:id/sleep_records/clock_in
      # Clock in a sleep record for a user
      # @param [Integer] id User ID
      # @return [Array<SleepRecord>] List of user's sleep records
      def clock_in
        sleep_record = SleepRecords::ClockInService.call(@user.id)
        render json: [ sleep_record ], status: :created
      rescue Api::V1::Errors::BaseError => e
        render json: { error: e.message }, status: e.status
      end

      # POST /api/v1/users/:id/sleep_records/:sleep_record_id/clock_out
      # Clock out a sleep record
      # @param [Integer] id User ID
      # @param [Integer] sleep_record_id Sleep record ID
      # @return [SleepRecord] Updated sleep record
      def clock_out
        sleep_record = SleepRecords::ClockOutService.call(@user.id, @sleep_record.id)
        render json: sleep_record
      rescue Api::V1::Errors::BaseError => e
        render json: { error: e.message }, status: e.status
      end

      # GET /api/v1/users/:id/sleep_records/following
      # Get sleep records of followed users from the last week
      # @param [Integer] id User ID
      # @return [Array<SleepRecord>] List of sleep records from followed users
      def following_records
        result = SleepRecords::FollowingRecordsService.call(
          @user.id,
          { page: params[:page], per_page: params[:per_page] }
        )

        if result.is_a?(Hash) && result[:message]
          render json: result, status: :ok
        else
          render json: {
            data: ActiveModelSerializers::SerializableResource.new(result[:data]),
            meta: result[:meta]
          }
        end
      rescue Api::V1::Errors::BaseError => e
        render json: { error: e.message }, status: e.status
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def set_sleep_record
        @sleep_record = @user.sleep_records.find(params[:sleep_record_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Sleep record not found" }, status: :not_found
      end
    end
  end
end
