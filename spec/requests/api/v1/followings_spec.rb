require 'swagger_helper'

RSpec.describe 'api/v1/followings', type: :request do
  let(:user) { User.create!(name: 'Test User') }
  let(:target_user) { User.create!(name: 'Target User') }
  let(:another_user) { User.create!(name: 'Another User') }

  path '/api/v1/users/{id}/follow/{target_id}' do
    post 'Follow a user' do
      description 'Allows a user to follow another user. A user cannot follow themselves or follow the same user twice.'
      tags 'Followings'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'ID of the user who wants to follow'
      parameter name: :target_id, in: :path, type: :integer, description: 'ID of the user to be followed'

      response '201', 'Successfully followed the user' do
        description 'Returns a success message when the follow relationship is created'
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Successfully followed the user' }
               }

        let(:id) { user.id }
        let(:target_id) { target_user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to be_present
          expect(user.following?(target_user)).to be true
        end
      end

      response '404', 'User not found' do
        description 'Returns an error when either the user or target user does not exist'
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'User not found' }
               }

        context 'when user does not exist' do
          let(:id) { 999999 }
          let(:target_id) { target_user.id }
          run_test!
        end

        context 'when target user does not exist' do
          let(:id) { user.id }
          let(:target_id) { 999999 }
          run_test!
        end
      end

      response '422', 'Unable to follow user' do
        description 'Returns an error when the follow operation is invalid'
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               examples: {
                 'self_follow': {
                   value: { error: 'Cannot follow yourself' }
                 },
                 'already_following': {
                   value: { error: 'Already following this user' }
                 }
               }

        context 'when trying to follow self' do
          let(:id) { user.id }
          let(:target_id) { user.id }
          run_test!
        end

        context 'when already following the user' do
          let(:id) { user.id }
          let(:target_id) { target_user.id }

          before do
            user.follow(target_user)
          end

          run_test!
        end
      end
    end
  end

  path '/api/v1/users/{id}/unfollow/{target_id}' do
    delete 'Unfollow a user' do
      description 'Allows a user to unfollow another user they are currently following'
      tags 'Followings'
      parameter name: :id, in: :path, type: :integer, description: 'ID of the user who wants to unfollow'
      parameter name: :target_id, in: :path, type: :integer, description: 'ID of the user to be unfollowed'

      response '204', 'Successfully unfollowed the user' do
        description 'Returns no content when the unfollow is successful'

        let(:id) { user.id }
        let(:target_id) { target_user.id }

        before do
          user.follow(target_user)
        end

        run_test! do |_response|
          expect(user.following?(target_user)).to be false
        end
      end

      response '404', 'User not found or not following' do
        description 'Returns an error when either user does not exist or when not following the target user'
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               examples: {
                 'user_not_found': {
                   value: { error: 'User not found' }
                 },
                 'not_following': {
                   value: { error: 'Not following this user' }
                 }
               }

        context 'when user does not exist' do
          let(:id) { 999999 }
          let(:target_id) { target_user.id }
          run_test!
        end

        context 'when target user does not exist' do
          let(:id) { user.id }
          let(:target_id) { 999999 }
          run_test!
        end

        context 'when not following the target user' do
          let(:id) { user.id }
          let(:target_id) { another_user.id }
          run_test!
        end
      end
    end
  end
end
