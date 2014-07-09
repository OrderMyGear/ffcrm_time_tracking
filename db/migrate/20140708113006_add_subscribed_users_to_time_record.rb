class AddSubscribedUsersToTimeRecord < ActiveRecord::Migration
  def change
    add_column :time_records, :subscribed_users, :text
  end
end
