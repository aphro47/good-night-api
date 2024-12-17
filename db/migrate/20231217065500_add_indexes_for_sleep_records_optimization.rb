class AddIndexesForSleepRecordsOptimization < ActiveRecord::Migration[7.1]
  def change
    # Composite index for user_id and created_at for efficient filtering and sorting
    unless index_exists?(:sleep_records, [:user_id, :created_at])
      add_index :sleep_records, [:user_id, :created_at]
    end
    
    # Add index for duration_minutes if it doesn't exist
    unless index_exists?(:sleep_records, :duration_minutes)
      add_index :sleep_records, :duration_minutes
    end
    
    # Add index for created_at if it doesn't exist
    unless index_exists?(:sleep_records, :created_at)
      add_index :sleep_records, :created_at
    end
    
    # Add composite index for followings if it doesn't exist
    unless index_exists?(:followings, [:follower_id, :followed_id])
      add_index :followings, [:follower_id, :followed_id], unique: true
    end
  end
end
