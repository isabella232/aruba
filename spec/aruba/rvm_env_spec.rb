require 'spec_helper'

require 'aruba/rvm_env'

RSpec.describe Aruba::RvmEnv do
  #
  # lets
  #

  let(:gems_path) {
    "#{rvm_path}/gems/"
  }

  let(:rubies_path) {
    "#{rvm_path}rubies/"
  }

  let(:rvm_path) {
    '/Users/alice/.rvm/'
  }

  context 'CONSTANTS' do
    context 'LINE_PARSER_PRECEDENCE' do
      subject(:line_parser_precedence) {
        described_class::LINE_PARSER_PRECEDENCE
      }

      it { is_expected.to eq([described_class::Prepend, described_class::Export, described_class::Unset]) }
    end
  end

  context 'change' do
    subject(:change) {
      described_class.change(
          from: from,
          to: to,
          world: world
      )
    }

    #
    # Methods
    #

    def rvm_env(options={})
      ruby_gemset = options.fetch(:ruby_gemset)
      ruby_version = options.fetch(:ruby_version)
      
      <<EOS
export PATH="#{gems_path}#{ruby_version}@#{ruby_gemset}/bin:#{gems_path}#{ruby_version}@global/bin:#{rubies_path}#{ruby_version}/bin:$PATH"
export GEM_HOME='#{gems_path}#{ruby_version}@#{ruby_gemset}'
export GEM_PATH='#{gems_path}#{ruby_version}@#{ruby_gemset}:#{gems_path}#{ruby_version}@global'
export MY_RUBY_HOME='#{rubies_path}#{ruby_version}'
export IRBRC='#{rubies_path}#{ruby_version}/.irbrc'
unset MAGLEV_HOME
unset RBXOPT
export RUBY_VERSION='#{ruby_version}'
EOS
    end

    #
    # lets
    #

    let(:from) {
      described_class.parse(
          rvm_env(
              ruby_gemset: from_ruby_gemset,
              ruby_version: from_ruby_version
          )
      )
    }
    
    let(:from_ruby_gemset) {
      'aruba'
    }

    let(:from_ruby_version) {
      'ruby-1.9.3-p547'
    }

    let(:to) {
      described_class.parse(
          rvm_env(
              ruby_gemset: to_ruby_gemset,
              ruby_version: to_ruby_version
          )
      )
    }

    let(:to_ruby_gemset) {
      'aruba_specs'
    }
    
    let(:to_ruby_version) {
      'ruby-2.1.2'
    }
    
    let(:world) {
      world_class.new
    }

    let(:world_class) {
      Class.new do
        include Aruba::Api
      end
    }

    #
    # Callbacks
    #

    before(:each) do
      # set up ENV to match `from`
      world.set_env('GEM_HOME', "#{gems_path}#{from_ruby_version}@#{from_ruby_gemset}")
      world.set_env('GEM_PATH', "#{gems_path}#{from_ruby_version}@#{from_ruby_gemset}:#{gems_path}#{from_ruby_version}@global")
      world.set_env('IRBRC', "#{rubies_path}#{from_ruby_version}/.irbrc")
      world.set_env('MY_RUBY_HOME', "#{rubies_path}#{from_ruby_version}")
      world.set_env('RUBY_VERSION', from_ruby_version)
    end

    after(:each) do
      world.stop_processes!
      world.restore_env
    end

    context 'GEM_HOME' do
      it 'changes ruby gemset and ruby version' do
        world.run 'env'

        expect(world.output_from('env')).to include("GEM_HOME=#{gems_path}#{from_ruby_version}@#{from_ruby_gemset}")

        change
        world.run 'env'

        expect(world.output_from('env')).to include("GEM_HOME=#{gems_path}#{to_ruby_version}@#{to_ruby_gemset}")
      end
    end

    context 'GEM_PATH' do
      it 'changes ruby gemset and ruby version, but leaves the global gemset' do
        world.run 'env'

        expect(world.output_from('env')).to include("GEM_PATH=#{gems_path}#{from_ruby_version}@#{from_ruby_gemset}:#{gems_path}#{from_ruby_version}@global")

        change
        world.run 'env'

        expect(world.output_from('env')).to include("GEM_PATH=#{gems_path}#{to_ruby_version}@#{to_ruby_gemset}:#{gems_path}#{to_ruby_version}@global")
      end
    end

    context 'IRBRC' do
      it 'changes ruby version' do
        world.run 'env'

        expect(world.output_from('env')).to include("IRBRC=#{rubies_path}#{from_ruby_version}/.irbrc")

        change
        world.run 'env'

        expect(world.output_from('env')).to include("IRBRC=#{rubies_path}#{to_ruby_version}/.irbrc")
      end
    end

    context 'MY_RUBY_HOME' do
      it 'changes ruby version' do
        world.run 'env'

        expect(world.output_from('env')).to include("MY_RUBY_HOME=#{rubies_path}#{from_ruby_version}")

        change
        world.run 'env'

        expect(world.output_from('env')).to include("MY_RUBY_HOME=#{rubies_path}#{to_ruby_version}")
      end
    end

    context 'PATH' do
      it 'changes ruby gemset and ruby version, but leaves the global gemset' do
        world.run 'env'

        expect(world.output_from('env')).to include("GEM_PATH=#{gems_path}#{from_ruby_version}@#{from_ruby_gemset}:#{gems_path}#{from_ruby_version}@global")

        change
        world.run 'env'

        expect(world.output_from('env')).to include("GEM_PATH=#{gems_path}#{to_ruby_version}@#{to_ruby_gemset}:#{gems_path}#{to_ruby_version}@global")
      end
    end

    context 'RUBY_VERSION' do
      it 'changes ruby version' do
        world.run 'env'

        expect(world.output_from('env')).to include("RUBY_VERSION=#{from_ruby_version}")

        change
        world.run 'env'

        expect(world.output_from('env')).to include("RUBY_VERSION=#{to_ruby_version}")
      end
    end
  end

  context 'parse' do
    subject(:parse) {
      described_class.parse(rvm_env)
    }

    #
    # shared examples
    #

    shared_examples_for 'parsed `rvm env`' do
      it { is_expected.to be_an(Array) }

      it 'includes an Aruba::RvmEnv::Export for GEM_HOME' do
        path = parse.find { |variable|
          variable.name == 'GEM_HOME'
        }

        expect(path).to be_a(Aruba::RvmEnv::Export)
      end

      it 'includes an Aruba::RvmEnv::Export for GEM_PATH' do
        path = parse.find { |variable|
          variable.name == 'GEM_PATH'
        }

        expect(path).to be_a(Aruba::RvmEnv::Export)
      end

      it 'includes an Aruba::RvmEnv::Export for IRBRC' do
        path = parse.find { |variable|
          variable.name == 'IRBRC'
        }

        expect(path).to be_a(Aruba::RvmEnv::Export)
      end

      it 'includes an Aruba::RvmEnv::Unset for MAGLEV_HOME' do
        path = parse.find { |variable|
          variable.name == 'MAGLEV_HOME'
        }

        expect(path).to be_a(Aruba::RvmEnv::Unset)
      end

      it 'includes an Aruba::RvmEnv::Export for MY_RUBY_HOME' do
        path = parse.find { |variable|
          variable.name == 'MY_RUBY_HOME'
        }

        expect(path).to be_a(Aruba::RvmEnv::Export)
      end

      it 'includes an Aruba::RvmEnv::Prepend for PATH' do
        path = parse.find { |variable|
          variable.name == 'PATH'
        }

        expect(path).to be_a(Aruba::RvmEnv::Prepend)
      end

      it 'includes an Aruba::RvmEnv::Export for RUBY_VERSION' do
        path = parse.find { |variable|
          variable.name == 'RUBY_VERSION'
        }

        expect(path).to be_a(Aruba::RvmEnv::Export)
      end
    end

    #
    # lets
    #

    let(:ruby_gemset) {
      'aruba'
    }
    
    let(:ruby_version) {
      'ruby-1.9.3-p547'
    }
    
    let(:rvm_path) {
      '/Users/alice/.rvm/'
    }

    context 'with combined export and set' do
      let(:rvm_env) {
        <<EOS
export PATH="#{gems_path}#{ruby_version}@#{ruby_gemset}/bin:#{gems_path}#{ruby_version}@global/bin:#{rubies_path}#{ruby_version}/bin:#{rvm_path}bin:$PATH"
export rvm_env_string='#{ruby_version}@#{ruby_gemset}'
export rvm_path='#{rvm_path}'
export rvm_ruby_string='#{ruby_version}'
export rvm_gemset_name='#{ruby_gemset}'
export RUBY_VERSION='#{ruby_version}'
export GEM_HOME='#{gems_path}#{ruby_version}@#{ruby_gemset}'
export GEM_PATH='#{gems_path}#{ruby_version}@#{ruby_gemset}:#{gems_path}#{ruby_version}@global'
export MY_RUBY_HOME='#{rubies_path}#{ruby_version}'
export IRBRC='#{rubies_path}#{ruby_version}/.irbrc'
unset MAGLEV_HOME
EOS
      }

      it_should_behave_like 'parsed `rvm env`'
    end

    context 'with separate export and set' do
      let(:rvm_env) {
        <<EOS
export PATH ; PATH="#{gems_path}#{ruby_version}@#{ruby_gemset}/bin:#{gems_path}#{ruby_version}@global/bin:#{rubies_path}#{ruby_version}/bin:#{rvm_path}bin:$PATH"
export rvm_env_string ; rvm_env_string='#{ruby_version}@#{ruby_gemset}'
export rvm_path ; rvm_path='#{rvm_path}'
export rvm_ruby_string ; rvm_ruby_string='#{ruby_version}'
export rvm_gemset_name ; rvm_gemset_name='#{ruby_gemset}'
export RUBY_VERSION ; RUBY_VERSION='#{ruby_version}'
export GEM_HOME ; GEM_HOME='#{gems_path}#{ruby_version}@#{ruby_gemset}'
export GEM_PATH ; GEM_PATH='#{gems_path}#{ruby_version}@#{ruby_gemset}:#{gems_path}#{ruby_version}@global'
export MY_RUBY_HOME ; MY_RUBY_HOME='#{rubies_path}#{ruby_version}'
export IRBRC ; IRBRC='#{rubies_path}#{ruby_version}/.irbrc'
unset MAGLEV_HOME
EOS
      }

      it_should_behave_like 'parsed `rvm env`'
    end
  end

  context 'parse_line' do
    subject(:parse_line) {
      described_class.parse_line(line)
    }

    context 'with export' do
      let(:line) {
        "export NAME='value'"
      }

      it { is_expected.to be_an Aruba::RvmEnv::Export }
    end

    context 'with prepend like with PATH' do
      let(:line) {
        'export PATH="/prepend/:$PATH"'
      }

      it { is_expected.to be_an Aruba::RvmEnv::Prepend }
    end

    context 'with unset' do
      let(:line) {
        'unset ENGINE_SPECIFIC'
      }

      it { is_expected.to be_an Aruba::RvmEnv::Unset }
    end

    context 'with unknown format' do
      let(:line) {
        'set FOO=BAR'
      }

      it 'raises ArgumentError with line in message' do
        expect {
          parse_line
        }.to raise_error(ArgumentError, "No line parser could parse #{line.inspect}")
      end
    end
  end

  context 'parsed_to_hash' do
    subject(:parsed_to_hash) {
      described_class.parsed_to_hash(parsed)
    }

    context 'with empty' do
      let(:parsed) {
        []
      }

      it { is_expected.to eq({}) }
    end

    context 'without empty' do
      let(:export) {
        Aruba::RvmEnv::Export.new(
            name: export_name,
            value: 'exported_value'
        )
      }

      let(:export_name) {
        'EXPORTED_NAME'
      }

      let(:parsed) {
        [
          export,
          prepend,
          unset
        ]
      }

      let(:prepend) {
        Aruba::RvmEnv::Prepend.new(
            name: prepend_name,
            value: '/prepended/value/:'
        )
      }

      let(:prepend_name) {
        'PREPENDED'
      }

      let(:unset) {
        Aruba::RvmEnv::Unset.new(
            name: unset_name
        )
      }

      let(:unset_name) {
        'UNSET'
      }

      it 'maps variable names to the varable' do
        expect(parsed_to_hash[export_name]).to eq(export)
        expect(parsed_to_hash[prepend_name]).to eq(prepend)
        expect(parsed_to_hash[unset_name]).to eq(unset)
      end
    end
  end
end