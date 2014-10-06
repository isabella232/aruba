shared_context 'Aruba::RvmEnv::Prepend' do
  let(:line) {
    %{export #{name}="#{value}$#{name}"}
  }

  let(:name) {
    'PATH'
  }

  let(:value) {
    '/usr/local/bin:'
  }
end