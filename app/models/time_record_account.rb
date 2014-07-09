class TimeRecordAccount < ActiveRecord::Base
  belongs_to :time_record
  belongs_to :account
end
