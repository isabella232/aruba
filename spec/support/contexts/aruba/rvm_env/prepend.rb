shared_context 'Aruba::RvmEnv::Prepend' do
  let(:line) {
    %Q{export #{name}="#{value}$#{name}"}
  }

  let(:name) {
    'PATH'
  }

  let(:value) {
    '/usr/local/bin:'
  }
end