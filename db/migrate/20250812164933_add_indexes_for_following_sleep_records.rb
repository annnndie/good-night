class AddIndexesForFollowingSleepRecords < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records,
              [:user_id, :created_at],
              name: 'index_sleep_records_on_user_created'
  end
end
