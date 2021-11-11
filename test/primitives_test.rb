require_relative 'test_helpers'
require_relative '../src/primitives'

class PrimitiveTest < Minitest::Test
  test "can be instantiated" do
    Primitive.new("")
  end
  test "has a type" do
  assert_equal :test, Primitive.new("", :test).type
  end
  test "requires stringy input" do
    assert_raises(ArgumentError) { Primitive.new(random_string.to_sym) }
    Primitive.new(random_string)
  end
end

class WhitespaceTest < Minitest::Test
  test "can be instantiated" do
    Primitive.new_whitespace("  \t\n\n \t\n")
  end
end

class PrimitiveNumberTest < Minitest::Test
  def setup
    @value = rand(100000000)
    @num = Primitive.new_number(@value.to_s)
  end
  test "can be instantiated" do
    assert Primitive.new_number(@value.to_s).is_a? Primitive
    assert @num.int?
  end
  test "stores lexeme" do
    assert_equal @value, @num.value
    assert_equal @value.to_s, @num.lexeme
  end
  test "stores floats correctly" do
    num = rand * 100
    pnum = Primitive.new_number(num.to_s)
    assert pnum.float?
    assert_equal num.to_s.to_f, pnum.lexeme.to_f
  end
end

class PrimitiveStringTest < Minitest::Test
  def setup
    @value = random_string
    @str = Primitive.new_string("\"#{@value}\"")
  end
  test "can be instantiated" do
    assert Primitive.new_string "\"#{random_string}\""
    assert_equal @value, @str.value
    assert_equal :str, @str.type
  end
end

class PrimitiveIdentifierTest < Minitest::Test
  test "can be instantiated" do
    Primitive.new_ident("im_an_identifier")
  end
  test "instantiates correctly" do
    value = "asdf"
    ident = Primitive.new_ident(value)
    assert_equal :identifier, ident.type
    assert_equal value, ident.value
  end
end

class PunctuationTest < Minitest::Test
  test "can be instantiated" do
    Primitive.new_punctuation("=")
  end
  test "instantiates correctly" do
    {'=' => :eq, '!' => :not, '(' => :begin_paren, ')' => :end_paren}.each do |input, expected_type|
      tokenizer = Tokenizer.new(input)
      tokenizer.next_lexeme
      assert_equal expected_type, tokenizer.value[0].type
      assert_equal input, tokenizer.value[0].value
    end
  end
  test "requires correctly-formed input" do
    assert_raises(ArgumentError) { Primitive.new_punctuation('(=)') }
    assert_raises(ArgumentError) { Primitive.new_punctuation('a') }
  end
end