require 'spec_helper'

require 'aruba/rvm_env'

RSpec.describe Aruba::RvmEnv::Prepend do
  context 'CONSTANTS' do
    context 'REGEXP' do
      subject(:regexp) {
        described_class::REGEXP
      }

      let(:name) {
        'PATH'
      }

      let(:prepend) {
        "#{name}=#{quote}#{value}$#{name}#{quote}"
      }

      let(:value) {
        '/Users/bob/.rvm/gems/ruby-1.9.3-p547@pro/bin:/Users/bob/.rvm/gems/ruby-1.9.3-p547@global/bin:/Users/bob/.rvm/rubies/ruby-1.9.3-p547/bin:/Users/bob/.rvm/bin:'
      }

      context 'with combined export and prepend' do
        let(:line) {
          "export #{prepend}"
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

      context 'with separate export and prepend' do
        let(:line) {
          "export #{name} ; #{prepend}"
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

      it { is_expected.to be_nil }
    end

    context 'with separate export and set' do
      include_context 'Aruba::RvmEnv::Export separate export and set'

      it { is_expected.to be_nil }
    end

    context 'with prepend' do
      include_context 'Aruba::RvmEnv::Prepend'

      it { is_expected.to be_a(described_class) }

      it 'extracts #name' do
        expect(parse.name).to eq(name)
      end

      it 'extracts #value' do
        expect(parse.value).to eq(value)
      end
    end

    context 'with unset' do
      include_context 'Aruba::RvmEnv::Unset'

      it { is_expected.to be_nil }
    end
  end

  context '#change' do
    subject(:change) {
      prepend.change(
          from: from,
          world: world
      )
    }

    #
    # lets
    #

    let(:from) {
      described_class.parse(
          %{export #{name}="/Users/alice/.rvm/gems/#{from_ruby_version}@aruba/bin:} +
          "/Users/alice/.rvm/gems/#{from_ruby_version}@global/bin:" \
          "/Users/alice/.rvm/rubies/#{from_ruby_version}/bin:" +
          %{$#{name}"}
      )
    }

    let(:from_ruby_version) {
      'ruby-1.9.3-p547'
    }

    let(:from_value_expanded) {
      "/Users/alice/.rvm/gems/#{from_ruby_version}@aruba/bin:" \
      "/Users/alice/.rvm/gems/#{from_ruby_version}@global/bin:" \
      "/Users/alice/.rvm/rubies/#{from_ruby_version}/bin:" \
      "/Users/alice/.rvm/bin:" \
      "/usr/local/bin:" \
      "/usr/local/sbin:" \
      "/opt/X11/bin:" \
      "/usr/bin:" \
      "/usr/sbin:" \
      "/bin:" \
      "/sbin"
    }

    let(:name) {
      'PATH'
    }

    let(:prepend) {
      described_class.parse(
          %{export #{name}="/Users/alice/.rvm/gems/#{ruby_version}@aruba/bin:} +
          "/Users/alice/.rvm/gems/#{ruby_version}@global/bin:" \
          "/Users/alice/.rvm/rubies/#{ruby_version}/bin:" +
          %{$#{name}"}
      )
    }

    let(:ruby_version) {
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
      world.set_env(name, from_value_expanded)
    end

    after(:each) do
      world.stop_processes!
      world.restore_env
    end

    it 'set the environment variable by swapping directories in path' do
      change
      world.run 'env'

      expect(world.all_output).to(
        include(
          "#{name}=/Users/alice/.rvm/gems/#{ruby_version}@aruba/bin:" \
          "/Users/alice/.rvm/gems/#{ruby_version}@global/bin:" \
          "/Users/alice/.rvm/rubies/#{ruby_version}/bin:" \
          "/Users/alice/.rvm/bin:" \
          "/usr/local/bin:" \
          "/usr/local/sbin:" \
          "/opt/X11/bin:" \
          "/usr/bin:" \
          "/usr/sbin:" \
          "/bin:" \
          "/sbin"
        )
      )
    end
  end
end