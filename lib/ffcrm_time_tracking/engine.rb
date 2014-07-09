require 'timespan'
require 'time_tracking_view_hooks'

module FfcrmTimeTracking
  class Engine < ::Rails::Engine
    initializer :load_config_initializers do
      config.paths["config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    config.to_prepare do
      require 'ffcrm_time_tracking/ability'
      require 'ffcrm_time_tracking/account'
      require 'ffcrm_time_tracking/project'
      require 'ffcrm_time_tracking/user'

      ActiveSupport.on_load(:fat_free_crm_project) do
        self.class_eval do
          include FfcrmTimeTracking::Project
        end
      end

      ActiveSupport.on_load(:fat_free_crm_account) do
        self.class_eval do
          include FfcrmTimeTracking::Account
        end
      end

      ActiveSupport.on_load(:fat_free_crm_user) do
        self.class_eval do
          include FfcrmTimeTracking::User
        end
      end

      ActiveSupport.on_load(:fat_free_crm_ability) do
        self.send(:prepend, FfcrmTimeTracking::Ability)
      end
    end
  end
end
