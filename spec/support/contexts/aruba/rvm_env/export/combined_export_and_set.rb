shared_context 'Aruba::RvmEnv::Export combined export and set' do
  include_context 'Aruba::RvmEnv::Export'

  let(:line) {
    %Q{export #{set}}
  }
end