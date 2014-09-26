shared_context 'Aruba::RvmEnv::Export' do
  let(:name) {
    'RUBY_VERSION'
  }

  let(:set) {
    %Q{#{name}='#{value}'}
  }

  let(:value) {
    'ruby-1.9.3-p547'
  }
end