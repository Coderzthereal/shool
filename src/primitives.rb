require_relative '../data/serializer'

class Primitive
  attr_accessor :value
  # USE #type TO FIGURE OUT WHAT IT IS
  # subclasses are for operators and input formatting
  # JKJKJK we aren't using subclasses :)))
  # 
  # be a duck typist
  attr_reader :lexeme, :type, :pos
  
  @@PUNC_TYPES = Serializer::Files.find{_1.id == :tokens}.object
  
  def initialize(pos, lexeme=nil, type=nil)
    raise ArgumentError, "lexeme must be stringy" unless lexeme.respond_to? :to_str
    @lexeme = lexeme.to_str
    @type = type
    @value = @lexeme if @type == :whitespace
  end
  def self.new_number(lexeme, pos)
    prim = Primitive.new(pos, lexeme)
    case lexeme
    when /\./
      prim.value = lexeme.to_f
      prim.instance_variable_set(:@type, :float)
    else
      prim.value = lexeme.to_i
      prim.instance_variable_set(:@type, :int)
    end
    prim
  end
  def self.new_string(lexeme, pos)
    str = Primitive.new(pos, lexeme, :str)
    raise ArgumentError, "lexeme doesn't describe a string" unless lexeme[0] == ?" and lexeme[-1] == ?"
    str.value = lexeme[1..-2]
    str
  end
  def self.new_ident(lexeme, pos)
    ident = Primitive.new(pos, lexeme, :identifier)
    ident.value = lexeme
    ident
  end
  # @@PUNC_TYPES = {?( => :begin_paren, ?) => :end_paren, "=" => :eq, ?! => :not, ?[ => :l_bracket, ?] => :r_bracket, ?{ => :l_curly, ?} => :r_curly, ?< => :lt, ?> => :gt, ?+ => :plus, ?- => :minus, ?* => :star, ?/ => :slash, ?: => :colon, "->" => :right_assign, "==" => :is_eq}
  def self.new_punctuation(lexeme, pos)
    raise ArgumentError, "invalid punctuation: '#{lexeme}'" unless @@PUNC_TYPES.keys.include? lexeme
    pnc = Primitive.new(pos, lexeme, @@PUNC_TYPES[lexeme])
    pnc.value = lexeme
    pnc
  end
  def self.new_newline(lexeme, pos)
    raise "lexeme must be only newlines" unless lexeme =~ /\A\n*\Z/
    nl = Primitive.new(pos, lexeme, :newline)
    nl.value = lexeme
    nl
  end
  def self.new_whitespace(lexeme, pos)
    raise "lexeme must be only whitespace" unless lexeme =~ /\A[\n\t ]*\Z/
    ws = Primitive.new(pos,lexeme, :whitespace)
    ws.value = lexeme
    ws
  end
  def int?
    @type == :int
  end
  def float?
    @type == :float
  end
  def str?
    @type == :str
  end
  def identifier?
    @type == :identifier
  end
	def eof?
		@type == :eof
	end
  def ==(other)
    @type == other.type and @lexeme == other.lexeme
  end
	def =~(regex)
		@type =~ regex
	end
  def inspect
    "<#Primitive pos: #@pos type: #@type lexeme: #{@lexeme.inspect}>"
  end
end