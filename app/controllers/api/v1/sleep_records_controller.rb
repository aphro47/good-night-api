module Api
  module V1
    class SleepRecordsController < BaseController
      include Pagy::Backend
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
        # Get the user's followed users' IDs with caching
        followed_user_ids = Rails.cache.fetch("user_#{params[:id]}_followed_ids", expires_in: 5.minutes) do
          Following.where(follower_id: params[:id]).pluck(:followed_id)
        end
        
        # Return early if user follows no one
        if followed_user_ids.empty?
          return render json: { message: "No followed users found" }, status: :ok
        end

        # Calculate date range for last week
        end_date = Time.current
        start_date = end_date - 1.week

        # Get records with pagination
        records = SleepRecord
          .includes(:user) # Eager load user to prevent N+1 queries
          .where(user_id: followed_user_ids)
          .where(created_at: start_date..end_date)
          .order(duration_minutes: :desc)

        # Calculate items per page with limits
        items_per_page = params[:per_page].to_i
        items_per_page = 20 if items_per_page <= 0
        items_per_page = [items_per_page, 100].min # Cap at 100 items

        # Initialize pagination
        @pagy, paginated_records = pagy(records, items: items_per_page)

        # Serialize the response
        render json: {
          data: ActiveModelSerializers::SerializableResource.new(paginated_records),
          meta: {
            page: @pagy.page,
            total_pages: @pagy.pages,
            total_count: @pagy.count,
            next_page: @pagy.next,
            prev_page: @pagy.prev,
            items_per_page: items_per_page
          }
        }
      rescue Pagy::OverflowError
        render json: { error: 'Page number out of bounds' }, status: :bad_request
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
