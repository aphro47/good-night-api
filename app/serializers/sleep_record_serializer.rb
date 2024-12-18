class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :clock_in_at, :clock_out_at, :duration_minutes, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer

  # Cache the serialization for 5 minutes
  cache key: "sleep_record", expires_in: 5.minutes
end
