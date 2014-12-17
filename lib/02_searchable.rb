require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line  = params.map { |key, _| "#{key} = ?"}.join(' AND ') 
    attribute_vals = params.values 
    results = DBConnection.execute(<<-SQL, *attribute_vals)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line};  
    SQL
    search_results = results.map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
