# All adjusts to timeouts should go in this file to ensure that the correct precedence between platform and tags is
# maintained

Before('~@gem-install') do
  if RUBY_PLATFORM == 'java'
    @aruba_timeout_seconds = 15
  else
    @aruba_timeout_seconds = 10
  end
end

# aruba is a very expensive gem to install because of the gherkin extensions
Before('@gem-install') do
  @aruba_timeout_seconds = 5 * 60
end