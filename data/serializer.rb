require 'yaml'

module Serializer
  module CustomSerializer; end
  Files = []
  Root = File.expand_path('..\..', __FILE__)
  class File
    attr_reader :path, :format, :id
    attr_accessor :object
    def initialize(path, id, obj=nil, format:)
      @path, @object, @id, @format = ::File.join(Serializer::Root, path), obj, id, format
      update_from_file if ::File.exists?(@path)
      
      Serializer::Files << self
    end
    def update_from_file
      case @format
      when 'yaml'
        @object = YAML.load_file(@path)
      when CustomSerializer
        @object = @format.deserialize_from(@path, @object)
      end
      self
    end
    def serialize_to_file
      case @format
      when 'yaml'
        str = @object.to_yaml
      when CustomSerializer
        str = @format.serialize(@object)
      end
      ::File.write(@path, str)
      self
    end
    alias obj object
    alias obj= object=
    alias filename path
  end
  at_exit do
    Files.each { _1.serialize_to_file }
  end
end

Serializer::File.new('data/tokens.yml', :tokens, format: 'yaml')