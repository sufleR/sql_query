# SqlQuery change log

## 0.7.5 / Unreleased

* [Added]

* [Deprecated]

* [Removed]

* [Fixed]

## 0.7.4 / 2024-04-20

* [Added] Remove upper restriction for rails

## 0.7.3 no changes

## 0.7.2 / 2022-01-23

* [Added] rails 7.0 as supported version https://github.com/sufleR/sql_query/pull/12

## 0.7.1 / 2021-12-14

* [Added] rails 6.1 as supported version https://github.com/sufleR/sql_query/pull/10

## 0.7.0 / 2020-08-04

* [Added] support for exec_query from ActiveRecord https://github.com/sufleR/sql_query/pull/7


## 0.6.0 / 2017-03-30

* [Added] possibility to override path where gem will look for sql file.

## 0.5.0 / 2016-04-26

* [Added] possibility to overwrite default connection class and connection directly using db_connection option.

## 0.4.0 / 2016-01-20

* [Added] execute will accept boolean attribute.
When set to false it will use raw query instead of prepared for logs.
By default it will be set to true.

## 0.3.0 / 2015-12-10

* [Added] support for partials

## 0.2.1 / 2015-05-01

* [Added] support for activerecord >= 3.2

* [Deprecated]

* [Removed]

* [Fixed]

## 0.2.0 / 2015-05-01

* [Added] First argument in initialize as sql file name with path

* [Deprecated] 

* [Removed] sql_name and sql_path in options hash

* [Fixed]

## 0.1.0 / 2015-04-27

* [Added] support for .erb.sql extension
