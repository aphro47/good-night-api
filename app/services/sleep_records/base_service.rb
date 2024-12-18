module SleepRecords
  class BaseService < ApplicationService
    private

    def validate_user!(user_id)
      User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      raise Api::V1::Errors::NotFoundError.new("User not found")
    end
  end
end
