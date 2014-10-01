source 'https://rubygems.org'
gemspec

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius-developer_tools'
end

gem 'childprocess', github: 'rapid7/childprocess', tag: 'v0.5.5.pre.unset.pre.in.pre.parent.pre.version.pre.bump'

# Use source from sibling folders (if available) instead of gems
# %w[cucumber].each do |g|
#   if File.directory?(File.dirname(__FILE__) + "/../#{g}")
#     @dependencies.reject!{|dep| dep.name == g}
#     gem g, :path => "../#{g}"
#   end
# end
