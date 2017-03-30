# frozen_string_literal: true

if ENV['BUILDER'] == 'travis'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'active_record'
require 'sql_query'
require 'pry'

SqlQuery.configure do |config|
  config.path = '/spec/sql_queries'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  connection = if ENV['BUILDER'] == 'travis'
                 'postgres://postgres@localhost/travis_ci_test'
               else
                 'postgres://sqlquery:sqlquery@localhost/sqlquery'
               end

  ActiveRecord::Base.establish_connection(connection)

  ActiveRecord::Base.connection.execute(
    'CREATE TABLE IF NOT EXISTS players (email text);'
  )

  config.order = :random
  Kernel.srand config.seed
end
