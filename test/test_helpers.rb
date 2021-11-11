require 'minitest/autorun'

class Module
  def test name, &block
    name.gsub!(/[^\w]+/, '_')
    self.define_method :"test_#{name}", &block
  end
end

class Object
  alias var_for instance_variable_get
end

def random_string(length=8)
  [*('a'..'z'),*('0'..'9'),*('A'..'Z')].shuffle[0,length].join
end

class Class
  def descendants
    ObjectSpace.each_object(::Class).select {|klass| klass < self }
  end
end