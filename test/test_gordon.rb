require 'odbc'

$dsn = ARGV.shift

$c = ODBC.connect($dsn, nil, nil)
$stmt = $c.prepare("select id, source_type from instadata.rds_data.product_sources limit 4")
if $stmt.column(0).name.upcase != "ID" then raise "fetch failed" end
if $stmt.column(1).name.upcase != "SOURCE_TYPE" then raise "fetch failed" end
$stmt.execute

# The code in /Users/gordonmccreight/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/bundler/gems/odbc_adapter-0309d0c0d6bc/lib/odbc_adapter/database_statements.rb
# uses .to_a on the statement
puts "expecting an id and a source type"
puts $stmt.to_a

# with TRACING enabled:

# SQLCall: SQLFetchScroll(SQL_FETCH_FIRST)
#   > HENV=0x0, HDBC=0x0, HSTMT=0x12c008a00
#   < SQL_ERROR
# ./compile_and_test: line 9: 29805 Abort trap: 6           ruby -I ../lib test_gordon.rb "MySnowflakeDSN"

#########################################################################
# logging
#########################################################################

# I added...
# LogLevel=6
# LogPath=/Users/gordonmccreight/snowflake_odbc_logs
# ... to my existing test DSN in ~/.odbc.ini
#
# which caused this file to be created.
# /Users/gordonmccreight/snowflake_odbc_logs/snowflake_odbc_connection_0.log
# and the end of that file looks like this

# 2023-09-11T16:40:04.867 TRACE 5061 Simba::ODBC::StatementState5::SQLFetchScroll: +++++ enter +++++
# 2023-09-11T16:40:04.868 ERROR 5061 Simba::ODBC::Statement::SQLFetchScroll: [Snowflake][ODBC] (10480) Fetch type not supported, as fetch orientation is not compatible with current settings.

$stmt.drop
$stmt.close
