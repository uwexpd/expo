require 'odbc_adapter'

# This is a monkey-patch to solve the "ArgumentError: time out of range" error that occurs when reading a student record
# that includes a date before 1970 or after 2038. From http://dev.rubyonrails.org/ticket/3430.
module ActiveRecord
  module ConnectionAdapters
    class ODBCAdapter < AbstractAdapter

      def convertOdbcValToGenericVal(value)
        # When fetching a result set, the Ruby ODBC driver converts all ODBC
        # SQL types to an equivalent Ruby type; with the exception of
        # SQL_TYPE_DATE, SQL_TYPE_TIME and SQL_TYPE_TIMESTAMP.
        #
        # The conversions below are consistent with the mappings in
        # ODBCColumn#mapSqlTypeToGenericType and Column#klass.
        res = value
        case value
        when ODBC::TimeStamp
          #PATCHED!
          #res = Time.gm(value.year, value.month, value.day, value.hour, value.minute, value.second)
          res = DateTime.new(value.year, value.month, value.day, value.hour, value.minute, value.second)
        when ODBC::Time
          now = DateTime.now
          res = Time.gm(now.year, now.month, now.day, value.hour,
            value.minute, value.second)
        when ODBC::Date
          res = Date.new(value.year, value.month, value.day)
        end
        res
      end
    end
  end
end
