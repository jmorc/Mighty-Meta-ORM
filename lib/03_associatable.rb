require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.to_s.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {}
    defaults[:foreign_key] = f_key(name)  
    defaults[:class_name] = c_name(name)
    defaults[:primary_key] = :id
    options = defaults.merge(options)
    
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
    
  end
  
  # String#singularize, String#camelcase, String#underscore
  
  def f_key(name)
    small_name = name.downcase
    f_key = small_name + '_id'
    f_key.to_sym
  end
  
  def c_name(name)
    name.camelcase
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {}
    defaults[:foreign_key] = f_key(self_class_name)  
    defaults[:class_name] = c_name(name)
    defaults[:primary_key] = :id
    options = defaults.merge(options)
    
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
  
  def f_key(name)
    small_name = name.downcase
    f_key = small_name + '_id'
    f_key.to_sym
  end
  
  def c_name(name)
    name.singularize.camelcase
  end
  
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
