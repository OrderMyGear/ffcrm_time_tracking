# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCRM
  class Tabs
    class << self
      def main_with_time_tracking
        @@main ||= begin
          tabs = main_without_time_tracking

          if Setting[:time_tracking] && (tab = Setting[:time_tracking][:tab])
            tabs << tab
          end

          tabs
        end
      end

      alias_method_chain :main, :time_tracking
    end
  end
end
