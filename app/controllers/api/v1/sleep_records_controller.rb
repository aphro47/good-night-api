module Api
  module V1
    class SleepRecordsController < BaseController
      before_action :set_user
      before_action :set_sleep_record, only: [:clock_out]

      # POST /api/v1/users/:id/sleep_records/clock_in
      # Clock in a sleep record for a user
      # @param [Integer] id User ID
      # @return [Array<SleepRecord>] List of user's sleep records
      def clock_in
        @sleep_record = @user.sleep_records.build(clock_in_at: Time.current)

        if @sleep_record.save
          render json: @user.sleep_records.ordered_by_created, status: :created
        else
          render json: @sleep_record.errors, status: :unprocessable_entity
        end
      end

      # POST /api/v1/users/:id/sleep_records/:sleep_record_id/clock_out
      # Clock out a sleep record
      # @param [Integer] id User ID
      # @param [Integer] sleep_record_id Sleep record ID
      # @return [SleepRecord] Updated sleep record
      def clock_out
        if @sleep_record.update(clock_out_at: Time.current)
          render json: @sleep_record, status: :ok
        else
          render json: @sleep_record.errors, status: :unprocessable_entity
        end
      end

      # GET /api/v1/users/:id/sleep_records/following
      # Get sleep records of followed users from the last week
      # @param [Integer] id User ID
      # @return [Array<SleepRecord>] List of sleep records from followed users
      def following_records
        following_ids = @user.followed_user_ids
        
        @records = SleepRecord.where(user_id: following_ids)
                             .last_week
                             .with_duration
                             .ordered_by_duration
                             .includes(:user)

        render json: @records, include: :user
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def set_sleep_record
        @sleep_record = @user.sleep_records.find(params[:sleep_record_id])
      end
    end
  end
end
