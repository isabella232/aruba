shared_context 'Aruba::RvmEnv::Unset' do
  let(:line) {
    "unset #{name}"
  }

  let(:name) {
    'MAGLEV_HOME'
  }
end