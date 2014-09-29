require 'spec_helper'

require 'aruba/rvm_env'

RSpec.describe Aruba::RvmEnv::Export do
  context 'CONSTANTS' do
    context 'REGEXP' do
      subject(:regexp) {
        described_class::REGEXP
      }

      let(:name) {
        'rvm_env_string'
      }

      let(:set) {
        "#{name}=#{quote}#{value}#{quote}"
      }

      let(:value) {
        'ruby-1.9.3-p547@pro'
      }

      context 'with combined export and set' do
        let(:line) {
          "export #{set}"
        }

        context 'with "' do
          let(:quote) {
            '"'
          }

          it 'matches groups correctly' do
            expect(regexp).to match(line)

            match = regexp.match(line)

            expect(match[:name]).to eq(name)
            expect(match[:value]).to eq(value)
          end
        end

        context "with '" do
          let(:quote) {
            "'"
          }

          it 'matches groups correctly' do
            expect(regexp).to match(line)

            match = regexp.match(line)

            expect(match[:name]).to eq(name)
            expect(match[:value]).to eq(value)
          end
        end
      end

      context 'with separate export and set' do
        let(:line) {
          "export #{name} ; #{set}"
        }

        context 'with "' do
          let(:quote) {
            '"'
          }

          it 'matches groups correctly' do
            expect(regexp).to match(line)

            match = regexp.match(line)

            expect(match[:name]).to eq(name)
            expect(match[:value]).to eq(value)
          end
        end

        context "with '" do
          let(:quote) {
            "'"
          }

          it 'matches groups correctly' do
            expect(regexp).to match(line)

            match = regexp.match(line)

            expect(match[:name]).to eq(name)
            expect(match[:value]).to eq(value)
          end
        end
      end
    end
  end

  context 'parse' do
    subject(:parse) do
      described_class.parse(line)
    end

    context 'with combined export and set' do
      include_context 'Aruba::RvmEnv::Export combined export and set'

      it { is_expected.to be_a(described_class) }

      it 'extracts #name' do
        expect(parse.name).to eq(name)
      end

      it 'extracts #value' do
        expect(parse.value).to eq(value)
      end
    end

    context 'with separate export and set' do
      include_context 'Aruba::RvmEnv::Export separate export and set'

      it { is_expected.to be_a(described_class) }

      it 'extracts #name' do
        expect(parse.name).to eq(name)
      end

      it 'extracts #value' do
        expect(parse.value).to eq(value)
      end
    end

    context 'with prepend' do
      include_context 'Aruba::RvmEnv::Prepend'

      it "is Aruba::RvmEnv::Export because Aruba::RvmEnv::Prepend's pattern is a subset of Aruba::RvmEnv::Export's pattern" do
        expect(parse).to be_a(described_class)
      end

      it 'extracts #name' do
        expect(parse.name).to eq(name)
      end

      it 'erroneously extracts #value with appended #name' do
        expect(parse.value).to eq("#{value}$#{name}")
      end
    end

    context 'with unset' do
      include_context 'Aruba::RvmEnv::Unset'

      it { is_expected.to be_nil }
    end
  end

  context '#==' do
    subject(:double_equals) {
      export == other
    }

    let(:export) {
      described_class.new(
          name: name,
          value: value
      )
    }

    let(:name) {
      'RUBY_VERSION'
    }

    let(:value) {
      'ruby-1.9.3-p547'
    }

    context 'with another Aruba::RvmEnv::Export' do
      let(:other) {
        described_class.new(
            name: other_name,
            value: other_value
        )
      }

      context 'with same #name' do
        let(:other_name) {
          name
        }

        context 'with same #value' do
          let(:other_value) {
            value
          }

          it { is_expected.to eq(true) }
        end

        context 'with different #value' do
          let(:other_value) {
            'ruby-2.1.2'
          }

          it { is_expected.to eq(false) }
        end
      end

      context 'with different #name' do
        let(:other_name) {
          'MY_RUBY_HOME'
        }

        context 'with same #value' do
          let(:other_value) {
            value
          }

          it { is_expected.to eq(false) }
        end

        context 'with different #value' do
          let(:other_value) {
            '/Users/alice/.rvm/rubies/ruby-2.1.2'
          }

          it { is_expected.to eq(false) }
        end
      end
    end
  end

  context '#change' do
    subject(:change) {
      export.change(world: world)
    }

    #
    # lets
    #

    let(:export) {
      described_class.new(
          name: name,
          value: value
      )
    }

    let(:name) {
      'EXPORTED_NAME'
    }

    let(:value) {
      'exported-value'
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

    after(:each) do
      world.stop_processes!
      world.restore_env
    end

    it 'sets the environment variables with #name to #value' do
      change
      world.run 'env'
      expect(world.all_output).to include("#{name}=#{value}")
    end
  end
end