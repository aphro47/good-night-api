require 'swagger_helper'

RSpec.describe 'api/v1/sleep_records', type: :request do
  path '/api/v1/users/{id}/sleep_records/clock_in' do
    post 'Clock in a sleep record' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      response '201', 'sleep record created' do
        schema type: :array,
               items: {
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
                 required: ['id', 'user_id', 'clock_in_at']
               }

        let(:id) { User.create!(name: 'Test User').id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/sleep_records/{sleep_record_id}/clock_out' do
    post 'Clock out a sleep record' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'
      parameter name: :sleep_record_id, in: :path, type: :integer, description: 'Sleep Record ID'

      response '200', 'sleep record updated' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 user_id: { type: :integer },
                 clock_in_at: { type: :string, format: 'date-time' },
                 clock_out_at: { type: :string, format: 'date-time' },
                 duration_minutes: { type: :integer },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: ['id', 'user_id', 'clock_in_at', 'clock_out_at', 'duration_minutes']

        let(:user) { User.create!(name: 'Test User') }
        let(:id) { user.id }
        let(:sleep_record) { user.sleep_records.create!(clock_in_at: 8.hours.ago) }
        let(:sleep_record_id) { sleep_record.id }
        run_test!
      end

      response '404', 'user or sleep record not found' do
        let(:id) { 'invalid' }
        let(:sleep_record_id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/sleep_records/following' do
    get 'Get sleep records of followed users' do
      tags 'Sleep Records'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      response '200', 'sleep records found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   user_id: { type: :integer },
                   clock_in_at: { type: :string, format: 'date-time' },
                   clock_out_at: { type: :string, format: 'date-time' },
                   duration_minutes: { type: :integer },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' },
                   user: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string }
                     }
                   }
                 }
               }

        let(:user) { User.create!(name: 'Test User') }
        let(:id) { user.id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
