# Mighty Meta ORM

This project employs metaprogramming to create an object-relational mapping (ORM), resulting in some of the features of ActiveRecord.  The project was completed as an exercise studying how ActiveRecord might be written to generate SQL queries and associations.

## Three features of interest:

**1. The `SQLObject` class plays the role of the `ActiveRecord::Base`.** The class method `::columns` (below) queries the sqlite3 database and returns an array of symbols corresponding to database column names. 

```ruby
class SQLOjbect
  def self.columns
    column_query = DBConnection::execute2(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL
    symbols = column_query.first.map { |el| el.to_sym }
  end
end
```
Using `::columns`, a SQLObject may be initialized with a hash of attribute names and values.  Setter methods corresponding to the attributes are also created when a SQLObject is initialized:

```ruby
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
```

**2. Metaprogramming (Ruby's `define_method`) is used to generate setter and getter methods corresponding to the data column names whenever a `SQLObject` is finalized:**

```ruby
class SQLObject
  def self.finalize!
    cols = self.columns
    cols.each do |col|
      setter_name = col.to_s + '='
      define_method(col) { self.attributes[col] }
      define_method(setter_name) { |arg| self.attributes[col] = arg } 
    end 
  end
end
```  

**3. `define_method` is also used to generate associations.**  For example, the `#belongs_to` method takes in a name for the association and an options hash.  Initially, the options related to the association are stored in `assoc_options`.  Then, `define_method` is used to create the association method.  This method is a macro that builds and fires a SQL query for the target data object. 

```ruby
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options) 
    assoc_options[name] = options
    
    define_method(name) do 
      id_value = self.send(:id)
      model_class = options.model_class
      params = { options.primary_key => id_value }
      data_object = model_class.where(params)
      data_object.first
    end
  end
```

## Detailed project description:

### `SQLObject` class

This class facilitates querying the database, finding database entries, and and creating and modifying of objects from database entries, much like the 'ActiveRecord::Base' class.  Features of 'SQLObject' include:

* `::all` Returns an array of objects representing each item in the database.  
* `::find` Finds a row of data by id number and returns an object representing the entry.
* `#insert` Add a new entry to the database from an instance of 'SQLObject'.
* `#update` Updates a row of data with changes made on the corresponding `SQLOjbect`.
* `#save` Saves an entry to the database by calling '#insert' if it is a new row of data or '#update' if an existing row is being modified.

### `Searchable` module

The `Searchable` module is mixed in to `SQLObject`, facilitating find and retrieve operations.  This module adds the `#where(params)` method.

### `AssocOptions` class and `Associatable` module 

These components are used to define the `belongs_to` and `has_many` methods, used to create associations between model classes.  

* `AssocOptions` and child classes `HasManyOptions` and `BelongsToOptions` provide the default foreign key, primary key, and class name for an association.  They also permit overwriting the defaults.  

* `belongs_to` and `has_many` both use the Ruby method `define_method(name)` to generate the association.  These generate associations (called `name`) that returns the associated data object(s) using the `where` method from the `Searchable` module. 

* `assoc_options` stores the options (names of the model class, foreign key, and primary key) related to a `belongs_to` association.  This is required for building `has_one_through` associations, as described below.   

### `Associatable_one_through` module 

This module adds the `has_one_through` type of association. This method again uses `define_method` to generate the `has_one_through` association method on the model class.  To generate the association, two `belongs_to` associations must be generated, and their options stored in `assoc_options`. These options are retrieved and used to generate the desired SQL query.
  


