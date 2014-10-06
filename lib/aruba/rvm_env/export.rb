module Aruba
  module RvmEnv
    # Recognizes `export`s of a variable
    class Export < Aruba::RvmEnv::Variable
      #
      # CONSTANTS
      #

      # Matches line with format `export <name>=<quote><value><quote>`
      REGEXP = /\Aexport (?<name>\S+?)(\s+;\s+\k<name>)?=(?<quote>"|')(?<value>.*?)\k<quote>\Z/

      #
      # Attributes
      #

      # @!attribute value
      #   The value to which {Aruba::RvmEnv::Variable#name} should be set
      #
      #   @return [String]
      attr_accessor :value

      #
      # Class Methods
      #

      # Parses line of `rvm env` output into an {Export} if it matches {REGEXP}.
      #
      # @param line [String] a line of `rvm env` output
      # @return [Export] if line contains `export`.
      # @return [nil] otherwise
      def self.parse(line)
        # use self:: so subclasses can override
        match = self::REGEXP.match(line)

        if match
          new(
            name: match[:name],
            value: match[:value]
          )
        end
      end

      #
      # Instance Methods
      #

      # @param attributes [Hash{Symbol=>String}]
      # @option attributes [String] :name (see Aruba::RvmEnv::Variable#name})
      # @option attributes [String] :value (see #value)
      def initialize(attributes={})
        super(name: attributes[:name])
        @value = attributes[:value]
      end

      # Whether this export is the same class and has the same {#value} as `other`.
      #
      # @return [true] if `other.class` is `Aruba::RvmEnv::Export` and `other.value` is {#value}.
      # @return [false] otherwise
      def ==(other)
        super(other) && other.value == self.value
      end

      # Set {Aruba::RvmEnv::Variable#name} to {#value}.
      #
      # @param options [Hash{Symbol => Object}]
      # @option options [Aruba::RvmEnv::Unset] :from the old state of this variable
      # @option options [Object] :world the cucumber world instance for the current scenario
      def change(options={})
        world = options.fetch(:world)

        world.set_env(name, value)
      end
    end
  end
end
