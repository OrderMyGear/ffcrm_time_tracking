class CreateTimeRecordAccounts < ActiveRecord::Migration
  def change
    create_table :time_record_accounts do |t|
      t.integer :time_record_id
      t.integer :account_id
      t.timestamps
    end

    add_index :time_record_accounts, [:time_record_id, :account_id]
  end
end
