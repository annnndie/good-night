class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :sleep_at, null: false
      t.datetime :wake_at
      t.integer :duration

      t.timestamps
    end
  end
end
