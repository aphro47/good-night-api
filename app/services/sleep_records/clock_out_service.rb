module SleepRecords
  class ClockOutService < BaseService
    def initialize(user_id, sleep_record_id)
      @user_id = user_id
      @sleep_record_id = sleep_record_id
    end

    def call
      user = validate_user!(@user_id)
      sleep_record = user.sleep_records.find_by(id: @sleep_record_id)

      raise Api::V1::Errors::NotFoundError.new("Sleep record not found") unless sleep_record
      raise Api::V1::Errors::ValidationError.new("Sleep record already completed") if sleep_record.clock_out_at.present?

      clock_out_time = Time.current
      sleep_record.update!(
        clock_out_at: clock_out_time,
        duration_minutes: ((clock_out_time - sleep_record.clock_in_at) / 60).to_i
      )

      sleep_record
    end
  end
end
