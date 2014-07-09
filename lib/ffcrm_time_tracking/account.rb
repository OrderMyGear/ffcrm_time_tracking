require 'active_support/concern'

module FfcrmTimeTracking
  module Account
    extend ActiveSupport::Concern

    included do
      has_many :time_record_accounts, :dependent => :destroy
      has_many :time_records, :through => :time_record_accounts
    end
  end
end