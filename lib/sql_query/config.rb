# frozen_string_literal: true

class SqlQuery
  # Configuration class for SqlQuery behavior
  #
  # @example
  #   SqlQuery.configure do |config|
  #     config.path = '/app/sql_queries'
  #     config.adapter = ActiveRecord::Base
  #     config.remove_comments = :all
  #     config.remove_comments_from = :prepared_for_logs
  #   end
  class Config
    attr_accessor :path, :adapter, :remove_comments, :remove_comments_from

    def initialize
      @path = '/app/sql_queries'
      @adapter = ActiveRecord::Base
      @remove_comments = :all        # :none, :oneline, :multiline, :all
      @remove_comments_from = :all   # :none, :prepared_for_logs, :all
    end

    # Determines if comments should be removed for a given context
    #
    # @param for_logs [Boolean] whether the query is being prepared for logs
    # @return [Boolean] true if comments should be removed
    def should_comments_be_removed?(for_logs:)
      case remove_comments_from
      when :prepared_for_logs
        for_logs
      when :all
        true
      else
        false
      end
    end
  end
end
