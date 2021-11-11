require_relative '../src/tokenizer'
require_relative '../src/parser'
require_relative 'runner'
$VER = '0.0.4'

class String
  # Finds the line surrounding a given index, e.g.
  #   str = "one\ntwo\nthree"
  #   index = 5
  #   str.line_around_index index
  #     => "two\n"
  def line_around_index index
    self[index] # to check for out of bounds because I'm lazy
		# Edge cases
    case index
    when 0
      lines.first
    when -1
      lines.last
    when length
      line_around_index -1
    else
			
			sum = 0
			lines.each do |line|
				sum += line.length
				return line if index <= sum
			end
			raise "something went wrong with String#line_around_index"
		end
  end
end

help_message = <<stop
HIC interpreter v#{$VER}
Usage: run filename.hic
stop
debug = true

ARGV.empty? ? (puts help_message; exit) : nil

processors = [Tokenizer, PostProcessor]

# at this point, we can assume not stdin
input = ARGF.readlines.join

begin
	runner = Runner.new(processors)
	value = runner.run(input)
rescue InterpreterHelper::Issue => e
	$stderr.puts "#{e.class}: #{e.message} (at pos #{e.pos})"
	$stderr.puts "\t#{input.line_around_index(e.pos)}"
	$stderr.puts "\t#{?^.rjust(e.pos-2)}"
	$stderr.puts e.backtrace if debug
	exit 1
end

puts " (!!!) Ran (!!!)"
puts "Finished value:\n\n"
puts value.map(&:inspect).join ?\n