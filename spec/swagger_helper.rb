# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Good Night API',
        version: 'v1',
        description: 'API for tracking sleep patterns and managing user relationships',
        contact: {
          name: 'API Support',
          email: 'support@example.com'
        }
      },
      paths: {},
      servers: [
        {
          url: '{protocol}://{defaultHost}',
          variables: {
            protocol: {
              default: 'http'
            },
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ],
      components: {
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: [ 'id', 'name' ]
          },
          SleepRecord: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              clock_in_at: { type: :string, format: 'date-time' },
              clock_out_at: { type: :string, format: 'date-time', nullable: true },
              duration_minutes: { type: :integer, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: [ 'id', 'user_id', 'clock_in_at' ]
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string }
            }
          }
        },
        securitySchemes: {
          # Add security schemes if needed
        }
      }
    }
  }

  config.openapi_format = :yaml
end
