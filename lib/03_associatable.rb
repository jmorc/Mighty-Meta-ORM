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
    model_class.to_s.downcase + "s"
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
  
  def f_key(name)
    small_name = name.to_s.downcase
    f_key = small_name + '_id'
    f_key.to_sym
  end
  
  def c_name(name)
    name.to_s.camelcase
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
    small_name = name.to_s.downcase
    f_key = small_name + '_id'
    f_key.to_sym
  end
  
  def c_name(name)
    name.to_s.singularize.camelcase
  end
  
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options) # make a BelongsToOptions obj
    
    define_method(name) do 
      f_id_value = self.send(:id)
     # f_keyname = options.f_key(name)
      model_class = options.model_class
      params = { id: f_id_value }
      # puts "f_keyname: #{f_keyname}, model_class: #{model_class}, f_id_value: #{f_id_value}"
      data_object = model_class.where(params)
      data_object.first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, options) # make a HasManyOptions obj
    
    define_method(name) do 
      f_id_value = self.send(:id)
      f_keyname = options.f_key(name)
      model_class = options.model_class
      params = { f_keyname.to_sym => f_id_value }
      # puts "f_keyname: #{f_keyname}, model_class: #{model_class}, f_id_value: #{f_id_value}"
      data_object = model_class.where(params)
      data_object.first
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
