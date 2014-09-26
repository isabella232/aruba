shared_context 'Aruba::RvmEnv::Export separate export and set' do
  include_context 'Aruba::RvmEnv::Export'

  let(:line) {
    %Q{export #{name} ; #{set}}
  }
end
