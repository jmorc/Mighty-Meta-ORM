require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    column_query = DBConnection::execute2(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL
    symbols = column_query.first.map { |el| el.to_sym }
  end

  def self.finalize!
    cols = self.columns

    cols.each do |col|
      setter_name = col.to_s + '='
      define_method(col) { self.attributes[col] }
      define_method(setter_name) { |arg| self.attributes[col] = arg } 
    end 
  end

  def self.table_name=(table_name)
    @table_name = table_name 
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    query = DBConnection.execute(<<-SQL)
    SELECT *
    FROM "#{self.table_name}"
    SQL
    retrieved_data_objects = query.map { |q| self.new(q) }  
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    query = DBConnection.execute(<<-SQL)
    SELECT *
    FROM "#{self.table_name}"
    WHERE id = #{id}
    SQL
    found_obj = self.new(query.first)
    
    # found_obj
  end

  def initialize(params = {})
    legit_cols = self.class.columns
  
    params.each do |col, val|
      unless  legit_cols.include?(col.to_sym)
        raise "unknown attribute '#{col}'"
      end  
      setter_method = col.to_s + '='
      self.send(setter_method.to_sym, val) 
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    cols = self.class.columns
    
    vals = cols.map do |col|
      self.send(col)
    end
  
    vals    
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(", ")
    question_marks = ["?"] * cols.count
    question_marks = question_marks.join(', ')
    attribute_vals = attribute_values
  
    DBConnection.execute(<<-SQL, *attribute_vals )
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
      SQL
    
     self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns
    set_text = cols.map { |col|  "#{col} = ?" }.join(", ")
    attribute_vals_with_id = attribute_values + [self.id]
    
    DBConnection.execute(<<-SQL, *attribute_vals_with_id )
    UPDATE
      #{self.class.table_name} 
    SET
      #{set_text} 
    WHERE
      id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
  
end
