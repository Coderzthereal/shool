module InterpreterHelper
	class Issue < RuntimeError; attr_reader :pos; def initialize(*args, pos); super(*args); @pos = pos; end; end
	@@error_classes = {}
	def error(error_str, pos="not given")
		layer = self.class
		@@error_classes[layer.to_s] ||= InterpreterHelper.create_error_class(layer.to_s)
		raise @@error_classes[layer.to_s].new(error_str, pos)
	end
	def self.create_error_class(layer_name)
		class_name = "#{layer_name}Issue"
		klass = Class.new(Issue)
		Object.const_set(class_name, klass)
		return eval(class_name)
	end
end