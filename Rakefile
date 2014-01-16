require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "capistrano-asl"
    gemspec.summary     = "asl deployment recipes for Capistrano"
    gemspec.description = "asl deployment recipes for Capistrano"
    gemspec.email       = "gunnar.marten@artcom.de"
    gemspec.homepage    = "https://github.com/artcom/capistrano-asl"
    gemspec.authors     = ["Gunnar Marten"]
    # Gem dependencies
    gemspec.add_dependency('capistrano', '= 2.15.5')
    gemspec.add_dependency('capistrano-ext')
    gemspec.add_dependency('railsless-deploy')

  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

