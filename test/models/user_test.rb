require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create!(name: "User 1")
    @user2 = User.create!(name: "User 2")
  end

  test "should follow and unfollow a user" do
    assert_not @user1.following?(@user2)

    @user1.follow(@user2)
    assert @user1.following?(@user2)

    @user1.unfollow(@user2)
    assert_not @user1.following?(@user2)
  end

  test "should not follow self" do
    @user1.follow(@user1)
    assert_not @user1.following?(@user1)
  end
end
