# frozen_string_literal: true

require 'erb'

class SqlQuery
  attr_reader :connection

  def initialize(file_name, options = {})
    unless file_name.is_a?(String) || file_name.is_a?(Symbol)
      raise ArgumentError, 'SQL file name should be String or Symbol'
    end

    @sql_filename = file_name
    @options = options
    @connection = options.try(:delete, :db_connection) ||
                  self.class.config.adapter.connection
    prepare_variables
  end

  def explain
    msg = "EXPLAIN for: \n#{sql}\n"
    msg += connection.explain(sql)
    pretty(msg)
  end

  def execute(prepare = true)
    to_execute = prepare ? prepared_for_logs : sql
    connection.execute(to_execute).entries
  end

  def exec_query(prepare = true)
    to_execute = prepare ? prepared_for_logs : sql
    connection.exec_query(to_execute).to_a
  end

  def sql
    @sql ||= prepare_query(false)
  end

  def pretty_sql
    pretty(sql.dup)
  end

  def quote(value)
    connection.quote(value)
  end

  def prepared_for_logs
    @prepared_for_logs ||= prepare_query(true)
  end

  def partial(partial_name, partial_options = {})
    path, file_name = split_to_path_and_name(partial_name)
    self.class.new("#{path}/_#{file_name}",
                   @options.merge(partial_options)).sql
  end

  attr_writer :config

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end

  class Config
    attr_accessor :path, :adapter

    def initialize
      @path = '/app/sql_queries'
      @adapter = ActiveRecord::Base
    end
  end

  private

  def prepare_query(for_logs)
    query_template = File.read(file_path)
    query_template = query_template.gsub(/(\n|\s)+/, ' ') if for_logs
    ERB.new(query_template).result(binding)
  end

  def split_to_path_and_name(file)
    if file.is_a?(Symbol)
      ['', file.to_s]
    else
      parts = file.rpartition('/')
      [parts.first, parts.last]
    end
  end

  def pretty(value)
    # override inspect to be more human readable from console
    # code copy from ActiveRecord
    # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/explain.rb#L30
    def value.inspect
      self
    end
    value
  end

  def prepare_variables
    return if @options.blank?

    @options.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def file_path
    files = Dir.glob(path)
    if files.empty?
      raise "File not found: #{@sql_filename}"
    elsif files.size > 1
      raise "More than one file found: #{files.join(', ')}"
    else
      files.first
    end
  end

  def path
    if @sql_file_path.present?
      tmp_path = @sql_file_path
    else
      root = defined?(Rails) ? Rails.root.to_s : Dir.pwd
      tmp_path = "#{root}#{self.class.config.path}"
    end
    tmp_path += "/#{@sql_filename}.{sql.erb,erb.sql}"
    tmp_path
  end
end
