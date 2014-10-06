require 'aruba/spawn_process'

module Aruba
  autoload 'RvmEnv', 'aruba/rvm_env'

  class << self
    attr_accessor :process
  end
  self.process = Aruba::SpawnProcess
end
