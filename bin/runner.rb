class Runner
	def initialize(processors)
		@processors = processors
		@current_processor = @processors.shift # Remove first element
		@value = nil
	end
	def next_processor
		processor = @current_processor.new(@value)
		processor.process
		@value = processor.value
		@current_processor = @processors.shift
	end
	def run(input)
		@value = input
		next_processor until @processors.empty?
		next_processor
		@value
	end
end