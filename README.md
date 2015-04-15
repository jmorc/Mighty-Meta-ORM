# Mighty Meta ORM

This project implements an object-relational mapping (ORM) system, mimicking in some of the features of ActiveRecord.  The project was completed as a studying of how ActiveRecord might generate SQL queries and handle associations.

## Features of interest:

**1. The `SQLObject` is similar to the `ActiveRecord::Base`.** All models would inherit from this class.  It contains basic class methods, `::all` and `::find(id)`, to return models corresponding to the desired database entry (or entries).  It also includes instance methods `#insert`, `#update`, and `#save` which generate the SQL code to interact with the database as expected. 

**2. Metaprogramming (Ruby's `define_method`) is used to generate getter and setter methods corresponding to the data column names whenever a `SQLObject` is finalized:**

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

**3. `define_method` is also used to generate associations.**  The `#belongs_to` method takes in a name for the association and an options hash.  Next, a `BelongsToOptions` object is initialized.  Similar to Rails, this allows the user to define association parameters (class name, foreign key, primary key), or else conventional defaults are set. The options related to the association are stored in `assoc_options`.  Then, `define_method` is used to create the association method. 

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
