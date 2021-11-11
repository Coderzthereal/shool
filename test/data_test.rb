require_relative 'test_helpers'
require_relative '../data/serializer'

class DataFileTest < Minitest::Test
  def setup
    @file = Serializer::File.new('test_name', :test, format: 'yaml')
  end
  test "can be instantiated" do
    assert @file.filename =~ /test_name$/
    assert_equal 'yaml', @file.format
  end
  test "stores an object" do
    @file.object = []
    num = rand
    srand num
    @file.obj << rand
    srand num
    assert_equal [rand], @file.object
  end
end