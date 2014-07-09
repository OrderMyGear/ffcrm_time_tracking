module FfcrmTimeTracking
  module Ability
    def initialize(user)
      super

      if user.present?
        # TimeRecord
        can :create, TimeRecord
        can :manage, TimeRecord, user_id: user.id
        can :manage, TimeRecord, assigned_to: user.id
      end
    end
  end
end