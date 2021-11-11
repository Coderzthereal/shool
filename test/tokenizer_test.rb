require_relative 'test_helpers'
require_relative '../src/tokenizer'
require_relative '../data/serializer'

class TokenizerTest < Minitest::Test
  def setup
    @input = random_string
    @tokenizer = Tokenizer.new(@input)
  end
  test "can be instantiated" do
    assert Tokenizer.new("some input")
  end
  test "requires input to instantiate" do
    assert_raises(ArgumentError) { Tokenizer.new }
  end
  test "only accepts stringy input" do
    assert_raises(ArgumentError) { Tokenizer.new(:not_io) }
    assert_raises(ArgumentError) { Tokenizer.new(0xbad) }
    assert Tokenizer.new('this should work')
    
    assert @tokenizer.var_for(:@input).is_a? StringScanner
    assert_equal (StringScanner.new(@input).string), @tokenizer.var_for(:@input).string
  end
  test "can be triggered" do
    tk = Tokenizer.new("\"hello\"\n")
    tk.process
    assert_equal 3, tk.value.size
    assert_equal "hello", tk.value[0].value
    assert_equal :str, tk.value[0].type
  end
  
  test "has a value" do
    refute_nil @tokenizer.value
  end
  test "doesn't have a random value" do
    assert @tokenizer.value.is_a? Array
  end
  test "responds to recognize lexeme" do
    @tokenizer.next_lexeme
  end
  
  # Lexemes
  test "recognizes ints" do
    input = rand(10000000).to_s
    value = Primitive.new_number(input)
    tokenizer = Tokenizer.new(input)
    tokenizer.next_lexeme
    assert_equal value, tokenizer.value[0]
  end
  test "recognizes floats" do
    input = (rand * 1000).to_s
    value = Primitive.new_number(input)
    tokenizer = Tokenizer.new(input)
    tokenizer.next_lexeme
    assert_equal value, tokenizer.value[0]
  end
  test "recognizes whitespace" do
    input = Primitive.new_whitespace(["\t", " "].shuffle.map{_1*rand(10)}.join.split(//).shuffle.join)
    tokenizer = Tokenizer.new(input.lexeme)
    tokenizer.next_lexeme
    assert_equal input, tokenizer.value[0]
  end
  test "recognizes string" do
    input = random_string
    tokenizer = Tokenizer.new("\"#{input}\"")
    tokenizer.next_lexeme
    assert_equal input, tokenizer.value[0].value
    assert_equal :str, tokenizer.value[0].type
  end
  test "recognizes identifiers" do
    input = ('a'..'z').to_a.shuffle[0] + random_string.gsub(/[^a-zA-Z_]/, '')
    tokenizer = Tokenizer.new(input)
    tokenizer.next_lexeme
    assert_equal input, tokenizer.value[0].value
    assert_equal :identifier, tokenizer.value[0].type
  end
  test "recognizes single char tokens" do
    tokens = Serializer::Files.find{_1.id==:tokens}.object
    input = tokens.keys[0..-3].join ''
    tokenizer = Tokenizer.new(input)
    tokenizer.process
    assert_equal input.size + 1, tokenizer.value.size # +1 is for EOF
    tokens.values[0..-3].map(&:to_sym).each.with_index do |expected_type, index|
      assert_equal input[index], tokenizer.value[index].value
      assert_equal expected_type, tokenizer.value[index].type
    end
  end
end

class PostProcessorTest < Minitest::Test
  # I've delegated two- and three-char tokens to a post-processor
  # it seemed like a good idea, it adds a processing layer that may
  # be useful, and it simplifies the tokenizer
  
  test "instantiates correctly" do
    assert_equal Class, PostProcessor.class
    PostProcessor.new([Primitive.new_string("\"some correct value\"")])
    assert_raises(ArgumentError) { PostProcessor.new }
    assert_raises(ArgumentError) { PostProcessor.new("not an array") }
  end
  test "post-processes correctly" do
    input = "->=="
    post_processor = PostProcessor.new(Tokenizer.new(input).process.value)
    post_processor.process
    %w{-> ==}.zip(%w{right_assign is_eq}.map(&:to_sym)).each.with_index do |var, index|
      lexeme, type = *var
      token = post_processor.value[index]
      assert_equal type, token.type
      assert_equal lexeme, token.lexeme
    end
  end
end