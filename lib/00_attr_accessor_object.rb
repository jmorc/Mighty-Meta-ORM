class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      ivar_name = '@' + name.to_s
      setter_name = name.to_s + '='
      define_method(name) { instance_variable_get(ivar_name.to_sym) }
      
      define_method(setter_name) do |arg| 
        instance_variable_set(ivar_name.to_sym, arg)
      end
    end
  end
end
