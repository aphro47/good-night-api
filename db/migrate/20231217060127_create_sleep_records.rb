class CreateSleepRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in_at, null: false
      t.datetime :clock_out_at
      t.integer :duration_minutes # Will be calculated when clock_out_at is set

      t.timestamps

      t.index [ :user_id, :created_at ]
      t.index [ :clock_in_at ]
      t.index [ :duration_minutes ]
    end
  end
end
