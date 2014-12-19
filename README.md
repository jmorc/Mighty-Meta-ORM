# Mighty Meta ORM

This project employs metaprogramming to create an object-relational mapping (ORM) system. 

## Three features of interest:

**1. The `SQLObject` class plays the role of the `ActiveRecord::Base` class used in Rails.** For example, the class method `::columns` (below) queries the sqlite3 database and returns an array of symbols corresponding to database column names. 

```ruby
  def self.columns
    column_query = DBConnection::execute2(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL
    symbols = column_query.first.map { |el| el.to_sym }
  end
```

**2. Metaprogramming (Ruby's `define_method`) is used to generate setter and getter methods for the data columns whenever a `SQLObject` is finalized:**

```ruby
  def self.finalize!
    cols = self.columns
    cols.each do |col|
      setter_name = col.to_s + '='
      define_method(col) { self.attributes[col] }
      define_method(setter_name) { |arg| self.attributes[col] = arg } 
    end 
  end
```  

**3. `define_method` is also used to generate associations.**  In this example, associations exist between `Human`, `Cat`, and `House` model classes (seed data is defined in `cats.sql`). If a Cat `belongs_to` a Human, and a Human `has_many` Cats, the association methods, `Cat.human` and `Human.cats` are generated automatically by metaprogramming:

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

This class allows the creation of objects representing SQL data. It resembles the 'ActiveRecord::Base' class, used in as the parent class for models in a Rails app.  Features of the 'SQLObject' include:

* `::all` Returns an array of objects representing each item in the database.  
* `::find` Finds a row of data by id number and returns an object representing the entry.
* `#insert` Add a new entry to the database from an instance of 'SQLObject'.
* `#update` Updates a row of data with changes made on the corresponding `SQLOjbect`.
* `#save` Saves an entry to the database by calling '#insert' if it is a new row of data or '#update' if an existing row is being modified.

### `Searchable` module

The `Searchable` module is mixed in to the `SQLObject` class to add the capability to find and retrieve database entries by data attributes.  This module adds the `#where(params)` method.

### `AssocOptions` class and `Associatable` module 

These components are used to define the `belongs_to` and `has_many` methods, used to create associations between model classes.  

* `AssocOptions` and child classes `HasManyOptions` and `BelongsToOptions` are used to provide the default foreign key, primary key, and class name for an association.  They also permit the defaults to be overridden.  

* `belongs_to` and `has_many` both use the Ruby method `define_method(name)` to generate the association.  These generate associations (called `name`) that returns the associated data object(s) using the `where` method from the `Searchable` module. 

* `assoc_options` is a class instance method that stores the options related to a `belongs_to` association.  This is required for `has_one_through` associations, as described below.   

### `Associatable_one_through` module 

This module adds the `has_one_through` type of association. This method again uses `define_method` to generate the `has_one_through` association method on the model class.  To generate the association, two `belongs_to` associations must be generated, and their options stored in `assoc_options`. These options are retrieved and used to generate a SQL database query. The query creates and returns the correct data object.
  


