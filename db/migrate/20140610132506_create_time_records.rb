class CreateTimeRecords < ActiveRecord::Migration
  def change
    create_table :time_records do |t|
      t.integer :user_id
      t.integer :project_id

      t.integer :assigned_to
      t.integer :minutes_elapsed

      t.string  :category, limit: 32
      t.decimal :rate, precision: 12, scale: 2

      t.string :target, limit: 32
      t.text :description

      t.datetime :date_started
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :time_records, :user_id
    add_index :time_records, :project_id
    add_index :time_records, :assigned_to
  end
end
