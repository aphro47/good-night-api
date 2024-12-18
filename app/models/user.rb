class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  # Following relationships
  has_many :followings, foreign_key: :follower_id, dependent: :destroy
  has_many :followed_users, through: :followings, source: :followed

  # Follower relationships
  has_many :reverse_followings, class_name: "Following", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :reverse_followings, source: :follower

  validates :name, presence: true

  def follow(user)
    followed_users << user unless self == user || followed_users.include?(user)
  end

  def unfollow(user)
    followed_users.delete(user)
  end

  def following?(user)
    followed_users.include?(user)
  end
end
