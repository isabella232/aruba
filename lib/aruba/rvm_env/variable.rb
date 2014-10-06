module Aruba
  module RvmEnv
    # An environment variable in `rvm env`.
    class Variable
      #
      # Attributes
      #

      # @!attribute name
      #   The name of variable being manipulated in `rvm env`
      #
      #   @return [String]
      attr_accessor :name

      #
      # Instance Methods
      #

      # @param attributes [Hash{Symbol=>String}]
      # @option attributes [String] :name (see #name)
      def initialize(attributes={})
        @name = attributes[:name]
      end

      # This variable is the same class and has the same {#name} as `other`.
      #
      # @return [true] if `other.class` is `Aruba::RvmEnv::Variable` and `other.name` is {#name}.
      # @return [false] otherwise
      def ==(other)
        other.class == self.class && other.name == self.name
      end
    end
  end
end
