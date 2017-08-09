require 'bundler/setup'
require 'well_actually'
begin
  require 'rails'
  require 'active_record'
  require 'active_support'
  require "sqlite3"
  print "Rails Test"
rescue LoadError
  print "Non Rails Test"
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.establish_connection adapter: :sqlite3,
                                          database: ":memory:"
  load 'schema.rb'
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
