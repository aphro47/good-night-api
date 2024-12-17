require "test_helper"

class SleepRecordTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(name: "Test User")
    @sleep_record = @user.sleep_records.create!(
      clock_in_at: Time.current - 8.hours
    )
  end

  test "should calculate duration on clock out" do
    @sleep_record.update!(clock_out_at: Time.current)
    assert_not_nil @sleep_record.duration_minutes
    assert_equal 480, @sleep_record.duration_minutes # 8 hours = 480 minutes
  end

  test "should not allow clock out before clock in" do
    @sleep_record.clock_out_at = @sleep_record.clock_in_at - 1.hour
    assert_not @sleep_record.valid?
    assert_includes @sleep_record.errors[:clock_out_at], "must be after clock in time"
  end
end
