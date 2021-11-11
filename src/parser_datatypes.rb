class Tree
  attr_accessor :object
  attr_reader :children, :properties, :parent, :representations
  def initialize(obj)
    @object = obj
    @children = []
    @properties = {}
    @property_types = {}
    @property_updates = {}
    @representations = {}
    @parent = nil
    
    default_representations
  end
  # For flexibility
  # Doesn't propagate node properties
  def Tree.new_from_parent(obj, parent)
    tree = Tree.new(obj)
    tree.send :set_parent, parent
    tree
  end
  # Returns child--Tree.new(1) << 2 << 3 makes 3 a child of 2, not 1
  def <<(obj, &block)
    @children << Tree.new_from_parent(obj, self)
    @property_types.each { @children[-1].has_property _1, type: _2, pre_update_block: block, &@property_updates[_1] }
    @properties.keys.each{update_property _1 if @property_updates[_1]}
    @representations.keys.each { @children[-1].define_representation(_1, &@representations[_1]) }
    @children[-1]
  end
  def child
    raise "#child called with multiple children" unless @children.size == 1
    @children[0]
  end
  def siblings
    @parent.children
  end
  def grandparent
    @parent.parent
  end
  def root
    return self unless @parent
    @parent.root
  end
  def root?; !@parent; end
  
  def has_property(property, default_value=nil, type: [false, true], pre_update_block: nil, &dynamic_updates)
    (default_value = type[0]) unless default_value
    type = type.to_a if type.respond_to? :to_a
    @properties[property] = default_value
    @property_types[property] = type
    
    if dynamic_updates
      @property_updates[property] = dynamic_updates
			pre_update_block[self] if pre_update_block
      update_property property
    end
  end
  def set_property(property, value)
    raise ArgumentError, "Property #{property} does not exist" unless @property_types.keys.include?(property)
    validate_property_value property, value
    @properties[property] = value
  end
  def define_representation(representation, &elucidation)
    @representations[representation] = elucidation
  end
  def represent_as(representation)
    @representations[representation].call(self)
  end
  private def validate_property_value property, value
    type = @property_types[property]
    if type.is_a? Array
      raise ArgumentError, "invalid value for #{property}: #{value.inspect}" unless type.include? value
    else
      raise ArgumentError, "invalid value for #{property}: #{value.inspect}" unless type === value
    end
  end
  private def set_parent parent
    @parent = parent
  end
  def boolean_property? property
    type = @property_types[property]
    type.include?(true) and type.include?(false) and type.size == 2
  end
  # IMPORTANT: update order is self then children
  # Properties update on call, child creation, and property creation, but not grandchild creation
  def update_property property
    raise ArgumentError, "Property #{property} does not exist" unless @property_types[property]
    raise ArgumentError, "Property #{property} not dynamic" unless @property_updates[property]
    value = @property_updates[property][self]
    validate_property_value property, value
    @properties[property] = value
    @children.each{_1.update_property property}
  end
  def is property
    raise ArgumentError, "Property #{property} does not exist" unless @property_types.keys.include?(property)
    raise ArgumentError, "Non-boolean property: #{property}" unless boolean_property?(property)
    @properties[property] = true
  end
  def is?(property)
    raise ArgumentError, "Property #{property} does not exist" unless @property_types.keys.include?(property)
    raise ArgumentError, "Non-boolean property: #{property}" unless boolean_property?(property)
    @properties[property] == true
  end
  
  # Instantiate default conversions
  # i.e., inspect, to_s, etc.
  # CONSIDER extracting representation
  # system to own proj
  private def default_representations
    self.class.alias_method :__old_inspect, :inspect
    self.class.alias_method :__old_to_s, :to_s
    
    define_representation(:node_inspect) { _1.object.inspect }
    define_representation(:inspect) { _1.__old_inspect }
    define_representation(:to_s) { _1.__old_to_s }
    define_representation(:to_a) { [_1, _1.children.map(&:to_a)] }
  end
  def node_inspect
    represent_as :node_inspect
  end
  def inspect
    represent_as :inspect
  end
  def to_s
    represent_as :to_s
  end
  def to_a
    represent_as :to_a
  end
end

class ParseNode
	attr_reader :root, :pos, :type
	attr_accessor :tokens, :statement_type
	@@types = %w{expression statement root}
	@@statement_types = %w{none assign eval processing}
	def initialize(root: false, tokens: [], pos: 0, type:, statement_type: 'processing')
		raise "Improper ParseNode type: '#{type}'" unless @@types.include? type
		raise "Improper ParseNode statement type: '#{type}'" unless @@statement_types.include? statement_type
		
		@root, @tokens, @pos, @type, @statement_type = root, tokens, pos, type, statement_type
	end
	
	def [](var)
		{:root => @root, :tokens => @tokens, :pos => @pos, :type => @type, :statement_type => @statement_type}[var]
	end
	def []=(var, value)
		hash = {:root => @root, :tokens => @tokens, :pos => @pos, :type => @type, :statement_type => @statement_type}
		hash[var] = value
		%w{root tokens pos type statement_type}.each do |instvar|
			self.instance_variable_set("@#{instvar}", hash[instvar.to_sym])
		end
	end
end