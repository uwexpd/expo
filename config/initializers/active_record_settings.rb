ActiveRecord::Base.partial_updates = true

# From http://snippets.dzone.com/posts/show/5519 -- note that this is not transaction safe
# ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
#   def execute_with_retry_once(sql, name = nil)
#    retried = false
#    begin
#      execute_without_retry_once(sql, name)
#    rescue ActiveRecord::StatementInvalid => exception
#      ActiveRecord::Base.logger.info "#{exception}, retried? #{retried}"
# 
#      # Our database connection has gone away, reconnect and retry this method
#      reconnect!
#      unless retried
#        retried = true
#        retry
#      end
#    end
#   end
# 
#   alias_method_chain :execute, :retry_once
# 
# end

require 'find_and_sort'
ActiveRecord::Base.send :include, ActiveRecord::FindAndSort