module SleepRecords
  class ClockInService < BaseService
    def initialize(user_id)
      @user_id = user_id
    end

    def call
      user = validate_user!(@user_id)

      if user.sleep_records.in_progress.exists?
        raise Api::V1::Errors::ValidationError.new("Already have an in-progress sleep record")
      end

      user.sleep_records.create!(
        clock_in_at: Time.current
      )
    end
  end
end
