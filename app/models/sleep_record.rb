class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in_at, presence: true
  validate :clock_out_at_after_clock_in_at, if: :clock_out_at?

  scope :last_week, -> { where(created_at: 1.week.ago.beginning_of_day..Time.current) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :with_duration, -> { where.not(duration_minutes: nil) }
  scope :ordered_by_duration, -> { order(duration_minutes: :desc) }
  scope :in_progress, -> { where(clock_out_at: nil) }

  before_save :calculate_duration

  private

  def clock_out_at_after_clock_in_at
    if clock_out_at <= clock_in_at
      errors.add(:clock_out_at, "must be after clock in time")
    end
  end

  def calculate_duration
    if clock_in_at? && clock_out_at?
      self.duration_minutes = ((clock_out_at - clock_in_at) / 60).to_i
    end
  end
end
