require_relative 'associatable'
require_relative 'pluralize_fix'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      id_value = self.send(:id)
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.class_name.tableize
      through_table = through_options.class_name.tableize
      query = DBConnection.execute(<<-SQL, id_value)
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
      #{source_table} ON #{through_table}.#{source_options.foreign_key} = #{source_table}.id
      WHERE
        #{through_options.class_name.tableize}.id = ?
      SQL
      
      assoc_obj = source_options.class_name.constantize.new(query.first)
    end
  end
end
