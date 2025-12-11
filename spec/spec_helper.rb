# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'active_record'
require 'sql_query'
# require 'pry'

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

  connection_config = if ENV['CI']
                        {
                          adapter: 'postgresql',
                          host: 'localhost',
                          username: 'postgres',
                          password: 'postgres',
                          database: 'sqlquery_test'
                        }
                      else
                        {
                          adapter: 'postgresql',
                          host: 'localhost',
                          username: 'sqlquery',
                          password: 'sqlquery',
                          database: 'sqlquery'
                        }
                      end

  ActiveRecord::Base.establish_connection(connection_config)

  ActiveRecord::Base.connection.execute(
    'CREATE TABLE IF NOT EXISTS players (email text);'
  )

  config.order = :random
  Kernel.srand config.seed
end
