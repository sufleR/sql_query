require 'erb'

class SqlQuery
  attr_reader :connection

  def initialize(options = {})
    prepare_variables(options)
    @connection = ActiveRecord::Base.connection
  end

  def explain
    msg = "EXPLAIN for: \n#{ sql }\n"
    msg += connection.explain(sql)
    pretty(msg)
  end

  def execute
    connection.execute(prepared_for_logs).entries
  end

  def sql
    @sql ||= ERB.new(File.read(file_path)).result(binding)
  end

  def pretty_sql
    pretty(sql.dup)
  end

  def quote(value)
    connection.quote(value)
  end

  def prepared_for_logs
    sql.gsub(/(\n|\s)+/,' ')
  end

  def self.config=(value)
    @config = value
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end

  class Config
    attr_accessor :path

    def initialize
      @path = '/app/sql_queries'
    end
  end

  private

  def pretty(value)
    # override inspect to be more human readable from console
    # code copy from ActiveRecord
    # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/explain.rb#L30
    def value.inspect; self; end
    value
  end

  def prepare_variables(options)
    options.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def file_path
    files = Dir.glob(path)
    if files.size == 0
      raise "File not found with name: #{ @sql_name } in #{self.class.config.path}#{ @file_path }"
    elsif files.size > 1
      raise "More than one file found: #{ files.join(', ')}"
    else
      files.first
    end
  end

  def path
    root = defined?(Rails) ? Rails.root.to_s : Dir.pwd
    tmp_path = "#{ root }#{self.class.config.path}"
    tmp_path += "#{ @sql_path }/#{ @sql_name }.{sql.erb,erb.sql}"
    tmp_path
  end
end
