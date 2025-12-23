# frozen_string_literal: true

class SqlQuery
  # Service class responsible for normalizing whitespace in SQL queries
  # while preserving content within quoted strings.
  #
  # This class collapses multiple whitespace characters (spaces, tabs, newlines)
  # into single spaces, except when they appear within SQL string literals.
  #
  # @example
  #   normalizer = WhitespaceNormalizer.new
  #   sql = "SELECT *\n  FROM  users\n  WHERE name = '  John  '"
  #   normalizer.normalize(sql)
  #   # => "SELECT * FROM users WHERE name = '  John  '"
  class WhitespaceNormalizer
    # Normalizes whitespace in the given SQL string
    #
    # @param sql [String] the SQL string to normalize
    # @return [String] the normalized SQL string
    def normalize(sql)
      state = { in_single: false, in_double: false, prev_space: false }
      result = []
      i = 0

      i = process_character(sql, i, result, state) while i < sql.length

      result.join
    end

    private

    # rubocop:disable Metrics/MethodLength
    def process_character(sql, index, result, state)
      char = sql[index]

      if single_quote?(char, state)
        process_single_quote(sql, index, result, state)
      elsif double_quote?(char, state)
        process_double_quote(sql, index, result, state)
      elsif whitespace?(char)
        process_whitespace(char, result, state)
        index + 1
      else
        process_regular_char(char, result, state)
        index + 1
      end
    end

    def single_quote?(char, state)
      char == "'" && !state[:in_double]
    end

    def double_quote?(char, state)
      char == '"' && !state[:in_single]
    end

    def whitespace?(char)
      char =~ /\s/
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def process_single_quote(sql, index, result, state)
      if state[:in_single] && index + 1 < sql.length && sql[index + 1] == "'"
        # Doubled quote (escape) - add both
        result << sql[index] << sql[index + 1]
        state[:prev_space] = false
        index + 2
      else
        # Normal quote - toggle state
        state[:in_single] = !state[:in_single]
        result << sql[index]
        state[:prev_space] = false
        index + 1
      end
    end

    def process_double_quote(sql, index, result, state)
      if state[:in_double] && index + 1 < sql.length && sql[index + 1] == '"'
        # Doubled quote (escape) - add both
        result << sql[index] << sql[index + 1]
        state[:prev_space] = false
        index + 2
      else
        # Normal quote - toggle state
        state[:in_double] = !state[:in_double]
        result << sql[index]
        state[:prev_space] = false
        index + 1
      end
    end

    def process_whitespace(char, result, state)
      if state[:in_single] || state[:in_double]
        # Inside quotes: preserve whitespace
        result << char
        state[:prev_space] = false
      elsif !state[:prev_space]
        # Outside quotes: collapse to single space
        result << ' '
        state[:prev_space] = true
      end
    end

    def process_regular_char(char, result, state)
      result << char
      state[:prev_space] = false
    end
    # rubocop:enable Metrics/AbcSize
  end
end
