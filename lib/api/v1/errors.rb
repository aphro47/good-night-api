module Api
  module V1
    module Errors
      class BaseError < StandardError
        attr_reader :status

        def initialize(message, status = :unprocessable_entity)
          super(message)
          @status = status
        end
      end

      class NotFoundError < BaseError
        def initialize(message = "Resource not found")
          super(message, :not_found)
        end
      end

      class ValidationError < BaseError
        def initialize(message = "Validation failed")
          super(message, :unprocessable_entity)
        end
      end
    end
  end
end
