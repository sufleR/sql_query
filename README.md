[![Gem Version](https://badge.fury.io/rb/sql_query.svg)](http://badge.fury.io/rb/sql_query)
[![Code Climate](https://codeclimate.com/github/sufleR/sql_query/badges/gpa.svg)](https://codeclimate.com/github/sufleR/sql_query)
[![Test Coverage](https://codeclimate.com/github/sufleR/sql_query/badges/coverage.svg)](https://codeclimate.com/github/sufleR/sql_query)
[![Build Status](https://travis-ci.org/sufleR/sql_query.svg?branch=master)](https://travis-ci.org/sufleR/sql_query)

# SqlQuery

Ruby gem to load SQL queries from templates using ERB.

It makes working with pure SQL easier with syntax highlighting.

Let's you clean your Ruby code from SQL strings.

Supported extensions: `.sql.erb` or `.erb.sql`

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
> query = SqlQuery.new(:get_player_by_email, email: 'e@mail.dev')

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

### initialization

If you need to have nested paths to your queries like ```player/get_by_email``` just use string instead of symbol as file name.

Example:
```ruby
SqlQuery.new('player/get_by_email', email: 'e@mail.dev')
```

#### Special options

* db_connection - If you want to change default connection to database you may do it for every query execution using this option.
* sql_file_path - it will override default path where gem will look for sql file.

### Methods

- **execute** - executes query and returns result data. It accepts boolean argument. When argument is false it will run raw sql query instead of prepared_for_logs.
- **exec_query** - similar to `#execute` but with data returned via `ActiveRecord::Result`.
- **explain** - runs explain for SQL from template
- **sql** - returns SQL string
- **pretty_sql** - returns SQL string prettier to read in console
- **prepared_for_logs** - returns sql string without new lines and multiple whitespaces.

### Configuration

```ruby
# config/initializers/sql_query.rb
SqlQuery.configure do |config|
  config.path = '/app/sql_templates'
  config.adapter = ActiveRecord::Base
  config.remove_comments = :all              # :none, :oneline, :multiline, :all (default: :all)
  config.remove_comments_from = :all         # :none, :prepared_for_logs, :all (default: :all)
end
```

#### Configuration options
* path - If you don't like default path to your queries you can change it here.

* adapter - class which implements connection method.

* remove_comments - Controls which types of SQL comments to remove:
  * `:none` - Don't remove any comments
  * `:oneline` - Remove only single-line comments (`--`)
  * `:multiline` - Remove only multi-line comments (`/* */`)
  * `:all` - Remove both types (default)

* remove_comments_from - Controls where to apply comment removal:
  * `:none` - Don't remove comments anywhere
  * `:prepared_for_logs` - Remove comments only in `prepared_for_logs` method
  * `:all` - Remove comments from all queries (default)

**Note:** Comments within quoted strings (single quotes, double quotes, or PostgreSQL dollar quotes) are always preserved regardless of settings.

### Partials

You can prepare part of sql query in partial file and reuse it in multiple queries.

Partial file should start with '_'. 

Example:

```sql
# app/sql_queries/_email_partial.sql.erb
players.email = <%= quote @email %>
```

and use this partial like this:

```sql
SELECT *
FROM players
WHERE <%= partial :email_partial %>
```

## Examples

Check examples folder for some usefull queries.

If you have some examples to share please make pull request.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sql_query/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

To run specs, setup Postgres with the following:

```sql
CREATE DATABASE sqlquery;
CREATE ROLE sqlquery WITH LOGIN;
```
