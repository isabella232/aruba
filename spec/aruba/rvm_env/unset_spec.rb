require 'spec_helper'

require 'aruba/rvm_env'

RSpec.describe Aruba::RvmEnv::Unset do
  context 'CONSTANTS' do
    context 'REGEXP' do
      subject(:regexp) {
        described_class::REGEXP
      }

      let(:line) {
        "unset #{name}"
      }

      let(:name) {
        'RBXOPT'
      }

      it 'matches group correctly' do
        expect(regexp).to match(line)

        match = regexp.match(line)

        expect(match[:name]).to eq(name)
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

      it { is_expected.to be_nil }
    end

    context 'with unset' do
      include_context 'Aruba::RvmEnv::Unset'

      let(:line) {
        'unset MAGLEV_HOME'
      }

      it { is_expected.to be_a(described_class) }

      it 'extracts #name' do
        expect(parse.name).to eq(name)
      end
    end
  end

  context '#change' do
    subject(:change) {
      unset.change(world: world)
    }

    #
    # lets
    #

    let(:name) {
      'EXPORTED_NAME'
    }

    let(:from_value) {
      'exported-value'
    }

    let(:unset) {
      described_class.parse("unset #{name}")
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
      world.set_env(name, from_value)
    end

    after(:each) do
      world.stop_processes!
      world.restore_env
    end

    it 'removes environment variables with #name' do
      world.run 'env'

      expect(world.output_from('env')).to include("#{name}=#{from_value}")

      change
      world.run 'env'

      expect(world.output_from('env')).not_to include(name)
    end
  end
end