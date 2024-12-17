require 'swagger_helper'

RSpec.describe 'api/v1/followings', type: :request do
  path '/api/v1/users/{id}/follow/{target_id}' do
    post 'Follow a user' do
      tags 'Followings'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'
      parameter name: :target_id, in: :path, type: :integer, description: 'Target User ID to follow'

      response '201', 'successfully followed user' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               }

        let(:user) { User.create!(name: 'Test User') }
        let(:target_user) { User.create!(name: 'Target User') }
        let(:id) { user.id }
        let(:target_id) { target_user.id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        let(:target_id) { 'invalid' }
        run_test!
      end

      response '422', 'unable to follow user' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:user) { User.create!(name: 'Test User') }
        let(:id) { user.id }
        let(:target_id) { user.id } # Try to follow self
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/unfollow/{target_id}' do
    delete 'Unfollow a user' do
      tags 'Followings'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'
      parameter name: :target_id, in: :path, type: :integer, description: 'Target User ID to unfollow'

      response '204', 'successfully unfollowed user' do
        let(:user) { User.create!(name: 'Test User') }
        let(:target_user) { User.create!(name: 'Target User') }
        let(:id) { user.id }
        let(:target_id) { target_user.id }

        before do
          user.follow(target_user)
        end

        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        let(:target_id) { 'invalid' }
        run_test!
      end
    end
  end
end
