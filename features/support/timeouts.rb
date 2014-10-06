# All adjusts to timeouts should go in this file to ensure that the correct precedence between platform and tags is
# maintained

Before('~@slow') do
  if RUBY_PLATFORM == 'java'
    @aruba_timeout_seconds = 15
  else
    @aruba_timeout_seconds = 10
  end
end

Before('@slow') do
  @aruba_timeout_seconds = 5 * 60
end