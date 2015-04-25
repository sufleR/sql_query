[![Gem Version](https://badge.fury.io/rb/sql_query.svg)](http://badge.fury.io/rb/sql_query)
[![Dependency Status](https://gemnasium.com/sufleR/sql_query.svg)](https://gemnasium.com/sufleR/sql_query)
[![Code Climate](https://codeclimate.com/github/sufleR/sql_query/badges/gpa.svg)](https://codeclimate.com/github/sufleR/sql_query)
[![Test Coverage](https://codeclimate.com/github/sufleR/sql_query/badges/coverage.svg)](https://codeclimate.com/github/sufleR/sql_query)
[![Build Status](https://travis-ci.org/sufleR/sql_query.svg?branch=master)](https://travis-ci.org/sufleR/sql_query)

# SqlQuery

Ruby gem to load SQL queries from `.sql.erb` templates using ERB.

It makes working with pure SQL easier with syntax highlighting.

Let's you clean your Ruby code from SQL strings.

## Installation

Add this line to your application's Gemfile:

    gem 'sql_query'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sql_query

## Usage

Create SQL query in file in `app/sql_queries` directory

```sql
# app/sql_queries/get_player_by_email.sql.erb
SELECT *
FROM players
WHERE email = <%= quote @email %>
```
`quote` method is an alias to `ActiveRecord.connection.quote` method. You can use it to sanitize your variables for SQL.

You can use SQL like this:

```ruby
> query = SqlQuery.new(sql_name: :get_player_by_email, email: 'e@mail.dev')

> query.execute
   (0.6ms)  SELECT * FROM players WHERE email = 'e@mail.dev'
=> []

> query.explain
=> EXPLAIN for:
SELECT *
FROM players
WHERE email = 'e@mail.dev'

                        QUERY PLAN
----------------------------------------------------------
 Seq Scan on players  (cost=0.00..2.14 rows=1 width=5061)
   Filter: ((email)::text = 'e@mail.dev'::text)
(2 rows)

> query.sql
=> "SELECT *\nFROM players\nWHERE email = 'e@mail.dev'\n"

>  query.pretty_sql
=> SELECT *
FROM players
WHERE email = 'e@mail.dev'
```

### Methods

- **execute** - executes query and returns result data.
- **explain** - runs explain for SQL from template
- **sql** - returns SQL string
- **pretty_sql** - returns SQL string prettier to read in console
- **prepared_for_logs** - returns sql string without new lines and multiple whitespaces.

### Configuration

If you don't like default path to your queries you can configure it in initializer.

```ruby
# config/initializers/sql_query.rb
SqlQuery.configure do |config|
  config.path = '/app/sql_templates'
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sql_query/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
