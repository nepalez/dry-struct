if RUBY_ENGINE == 'rbx'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'pathname'

module DryStructSpec
  ROOT = Pathname.new(__dir__).parent.expand_path.freeze
end

$LOAD_PATH.unshift DryStructSpec::ROOT.join('lib').to_s

require 'dry-struct'

begin
  require 'byebug'
  require 'mutant'

  module Mutant
    class Selector
      class Expression < self
        def call(_subject)
          integration.all_tests
        end
      end # Expression
    end # Selector
  end # Mutant
rescue LoadError; end

Dir[Pathname(__dir__).join('shared/*.rb')].each(&method(:require))

RSpec.configure do |config|
  config.before do
    @types = Dry::Types.container._container.keys

    module Test
      def self.remove_constants
        constants.each { |const| remove_const(const) }
        self
      end
    end
  end

  config.after do
    container = Dry::Types.container._container
    (container.keys - @types).each { |key| container.delete(key) }
    Dry::Types.instance_variable_set('@type_map', Concurrent::Map.new)

    Object.send(:remove_const, Test.remove_constants.name)
  end
end
