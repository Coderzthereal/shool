require 'strscan'
require_relative 'mixins'
require_relative 'primitives'

class Tokenizer
	include InterpreterHelper
  attr_reader :value
  def initialize(input)
    # Input must be stringy
    raise ArgumentError, "input must be stringy--is a(n) #{input.class}" unless input.respond_to?(:to_str)
    
    # The space is required to offset StringScanner's pos onto the beginning of the input
    @input = StringScanner.new(input.to_str)
    @value = []
  end
  def process
    next_lexeme until @input.eos?
		@value << Primitive.new(-1, '', :eof)
    self
  end
  
  def next_lexeme
		pos = @input.pos
    if @input.scan(/\d+(\.\d+)?/)
      @value << Primitive.new_number(@input.matched, pos)
      return
    elsif @input.scan(/\n+/)
      @value << Primitive.new_newline(@input.matched, pos)
    elsif @input.scan(/[\t ]+/)
      @value << Primitive.new_whitespace(@input.matched, pos)
    elsif @input.scan(/"[^\n"]*"/)
      @value << Primitive.new_string(@input.matched, pos)
    elsif @input.scan(/[a-zA-Z0-9][a-zA-Z0-9_]*/)
      @value << Primitive.new_ident(@input.matched, pos)
    # Single-char tokens
    elsif @input.scan(/[()=!\[\]{}<>+\-*\/:;,\n]/)
      @value << Primitive.new_punctuation(@input.matched, pos)
    else
      error "unknown character ('#{@input.peek(1)}')", @input.pos+1
    end
  end
end

class PostProcessor
  attr_reader :value
  def initialize(input)
    raise ArgumentError, "wrong type of input" unless input.is_a?(Array)
    raise ArgumentError, "wrong types in input: #{input.map(&:class).uniq.map(&:to_s).join(', ')}" unless input.map(&:class).uniq == [Primitive]
    @input = input
    @value = nil
  end
  def process
    @value = @input
    
    # look at indexes--this creates [[0, 1], [1, 2], [2, 3], ...]
    # two-char operators: {'->' => :right_assign, '==' => :is_eq}
    
    # removed adds an offset since the assignment changes array length
    index = 0
    removed = 0
    @value[0..-2].zip(@value[1..-1]).each do |t_one, t_two|
      [[:minus, :gt, :right_assign], [:eq, :eq, :is_eq]].each do |type_one, type_two, expected|
        lex_one, lex_two = nil, nil
        if t_one.type == type_one and t_two.type == type_two
          lex_one, lex_two = t_one.lexeme, t_two.lexeme
          token = Primitive.new_punctuation(lex_one+lex_two, t_one.pos)
          raise "INTERNAL ERROR: token should be type #{expected.inspect} but is #{token.type.inspect} instead" unless token.type == expected

          # Next task: replace two tokens with their replacement
          # Not super difficult since #[]= supports this functionality
          # Array#[start, offset] = value => replaces range marked by
          #     start + offset w/value
          @value[index-removed, 2] = token
          removed += 1
          raise "FAILURE" unless token
        end
      end
      index += 1
    end
    self
  end
end