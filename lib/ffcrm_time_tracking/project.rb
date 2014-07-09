require 'active_support/concern'

module FfcrmTimeTracking
  module Project
    extend ActiveSupport::Concern

    included do
      has_many  :time_records, dependent: :destroy # do we really need to destroy time record?
    end
  end
end