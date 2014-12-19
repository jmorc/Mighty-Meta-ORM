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
    @foreign_key = options[:foreign_key] || f_key(name)
    @class_name = options[:class_name] || name.to_s.camelcase
    @primary_key = options[:primary_key] || :id
  end
  
  def f_key(name)
    small_name = name.to_s.downcase
    f_key = small_name + '_id'
    f_key.to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options) 
    # @assoc_options = { foreign_key: options.foreign_key,
#                        class_name: options.class_name,
#                        primary_key: options.primary_key }

    assoc_options[name] = options
    define_method(name) do 
      id_value = self.send(:id)
      model_class = options.model_class
      params = { options.primary_key => id_value }
      data_object = model_class.where(params)
      data_object.first
    end
  end

  def has_many(name, options = {})
    self_class_name = self.to_s
    options = HasManyOptions.new(name, self_class_name, options) 
    define_method(name) do 
      model_class = options.model_class
      f_id_value = self.send(:id)
      f_keyname = options.foreign_key
      params = { f_keyname.to_sym =>  f_id_value }
    
      data_object = model_class.where(params)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end


