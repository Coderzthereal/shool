require_relative 'mixins'
require_relative 'primitives'
require_relative 'parser_datatypes'
class Parser
	include InterpreterHelper
  attr_reader :tree
  def initialize(input)
    @source = input
		@tree = Tree.new(ParseNode.new root: true, type: 'root')
		@current_node = @tree
		@pos = 0
	end
	def process
		expect_statement until eof?
	end
	
	def expect_statement
		@current_node = (@current_node << ParseNode.new(type: 'statement')
		
		case current_token
		# Empty statements
		when /newline/
			consume_token
			@current_node.statement_type = 'none'
		when /identifier/
			if peek =~ /l_paren/
				# Eval statement
				
				@current_node.statement_type = 'eval'
			else
				consume_token
				skip_whitespace
				if peek =~ /right_assign/
					# Right assign
				elsif peek =~ /eq/
					# Assign
				@current_node.statement_type = 'assign'
			end
		when /(str|float|int)/
			# Right assign
		else	
			# TODO change this maybe? It's only here to generate the error message
			expect %w{newline identifier str float int}
		end
		
		@current_node = @current_node.parent
	end
	
	private
	def current_token
		@source[pos]
	end
	def peek
		@source[pos+1]
	end
	def expect(*types)
		types.flatten!
		if types.include? current_token.type
			consume_token
		else
			error "Expected #{(types.size>1 ? 'one of ' : 'a') + types.join(', ')}, got #{current_token.type} instead"
		end
	end
	def consume_token
		@current_node[:tokens] << current_token
		advance_token
	end
	def advance_token
		if eof?
			raise EOFError, "parser tried to read past end of file"
		end
		@pos += 1
	end
	def eof?
		current_token.type == :eof
	end
  alias_method :value, :tree
end