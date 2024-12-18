module SleepRecords
  class FollowingRecordsService < BaseService
    def initialize(user_id, options = {})
      @user_id = user_id
      @page = options[:page] || 1
      @per_page = options[:per_page] || 20
    end

    def call
      user = validate_user!(@user_id)
      followed_user_ids = fetch_followed_user_ids(user)

      return { message: "No followed users found" } if followed_user_ids.empty?

      records = fetch_sleep_records(followed_user_ids)
      paginate_records(records)
    end

    private

    def fetch_followed_user_ids(user)
      Rails.cache.fetch("user_#{user.id}_followed_ids", expires_in: 5.minutes) do
        user.followed_user_ids
      end
    end

    def fetch_sleep_records(followed_user_ids)
      SleepRecord
        .includes(:user)
        .where(user_id: followed_user_ids)
        .where(created_at: 1.week.ago..Time.current)
        .order(duration_minutes: :desc)
    end

    def paginate_records(records)
      items_per_page = @per_page.to_i
      items_per_page = 20 if items_per_page <= 0
      items_per_page = [ items_per_page, 100 ].min
      current_page = [ @page.to_i, 1 ].max

      total_count = records.count
      total_pages = (total_count.to_f / items_per_page).ceil
      offset = (current_page - 1) * items_per_page

      paginated_records = records.offset(offset).limit(items_per_page)

      {
        data: paginated_records,
        meta: {
          page: current_page,
          total_pages: total_pages,
          total_count: total_count,
          next_page: current_page < total_pages ? current_page + 1 : nil,
          prev_page: current_page > 1 ? current_page - 1 : nil,
          items_per_page: items_per_page
        }
      }
    end
  end
end
