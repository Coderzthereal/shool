require_relative 'test_helpers'
require_relative '../src/parser'

class ParserTest < Minitest::Test
  def setup
    @parser = Parser.new(["some input"])
  end
  test "can be instantiated" do
    Parser.new(["some input"])
  end
  test "requires input to instantiate" do
    assert_raises(ArgumentError) { Parser.new }
  end
  test "has a value" do
    refute_nil @parser.value
  end
  test "can be triggered" do
    parser = Parser.new(PostProcessor.new(Tokenizer.new("{\"hi\"->a}").process.value).process.value).process.value
  end
	test "can handle the three kinds of statements" do
		statements = []
		statements << '{"hi" -> a}'
		statements << '{b = 12345}'
		statements << '{method_call("hiiii")}'
		statements.each { Parser.new(PostProcessor.new(Tokenizer.new(_1).process.value).process.value).process.value }
	end
end