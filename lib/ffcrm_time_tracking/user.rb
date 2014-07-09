require 'active_support/concern'

module FfcrmTimeTracking
  module User
    extend ActiveSupport::Concern

    included do
      has_many :user_time_records, class_name: 'TimeRecord', foreign_key: :user_id
      has_many :assigned_time_records, class_name: 'TimeRecord', foreign_key: :assigned_to
    end
  end
end