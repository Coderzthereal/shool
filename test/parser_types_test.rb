require_relative 'test_helpers'
require_relative '../src/parser_datatypes'

class TreeTest < Minitest::Test
  test "can be instantiated" do
    Tree.new(Object.new)
  end
  test "stores an object" do
    assert_raises(ArgumentError) { Tree.new }
    value = Object.new
    assert_equal value, Tree.new(value).object
  end
  test "has children" do
    tree = Tree.new 7
    var = rand(20)
    tree << var
    refute_nil tree.children
    assert_equal var, tree.child.object
  end
  test "can have properties" do
    tree = Tree.new 17
    tree.has_property :edge_node, type: [false, true]
    tree << 36
    tree << 'a str'
    assert_equal false, tree.properties[:edge_node]
    assert_equal false, tree.is?(:edge_node)
    tree.children.each{_1.set_property(:edge_node, true)}
    tree.children.each{assert_equal true, _1.properties[:edge_node]}
    tree.is :edge_node
    assert tree.is? :edge_node
  end
  test "can have dynamic properties" do
    tree = Tree.new 17
    tree.has_property(:edge_node) { _1.children.empty? }
    assert tree.is? :edge_node
    5.times { tree << rand(100) }
    refute tree.is? :edge_node
    tree.children.each{assert _1.is? :edge_node}
  end
  test "Elucidates properly" do
    tree = Tree.new 17
    tree.has_property(:edge_node) { _1.children.empty? }
    
    tree.define_representation(:node_inspect) do |root|
      if root.is? :edge_node
        surround = ' '
      else
        surround = '|'
      end
      "#{surround}#{root.object}#{surround}"
    end
    assert_equal tree.represent_as(:node_inspect), ' 17 '
    
    rand(100).times { tree << rand(100) }
    # This should be exactly the same as using #represent,
    # as #node_inspect is a special case that should have
    # a default implementation
    assert_equal tree.node_inspect, '|17|'
  end
end