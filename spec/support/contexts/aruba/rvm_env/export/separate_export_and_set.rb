shared_context 'Aruba::RvmEnv::Export separate export and set' do
  include_context 'Aruba::RvmEnv::Export'

  let(:line) {
    "export #{name} ; #{set}"
  }
end
