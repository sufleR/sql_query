### File list:

* __distinct_values.sql.erb__ - implements "loose indexscan" in postgresql. More info [https://wiki.postgresql.org/wiki/Loose_indexscan](https://wiki.postgresql.org/wiki/Loose_indexscan)

```
SqlQuery.new(:distinct_values, table_name: :players, column_name: :player_type).execute

```
### 

