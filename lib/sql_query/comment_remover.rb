# frozen_string_literal: true

class SqlQuery
  # Service class responsible for removing SQL comments from queries
  # while preserving content within quoted strings.
  #
  # Supports SQL-92 standard comment syntax:
  # - Single-line comments: -- comment
  # - Multi-line comments: /* comment */
  #
  # Preserves content in:
  # - Single-quoted strings: '...'
  # - Double-quoted identifiers: "..."
  # - Dollar-quoted strings (PostgreSQL): $$...$$ or $tag$...$tag$
  #
  # @example
  #   remover = CommentRemover.new(:all)
  #   sql = "SELECT * FROM t -- comment\nWHERE id = 1"
  #   remover.remove(sql)
  #   # => "SELECT * FROM t \nWHERE id = 1"
  #
  # rubocop:disable Metrics/ClassLength
  class CommentRemover
    def initialize(strategy)
      @strategy = strategy # :none, :oneline, :multiline, :all
    end

    # Removes comments from SQL based on the configured strategy
    #
    # @param sql [String] the SQL string to process
    # @return [String] SQL with comments removed (or unchanged if strategy is :none)
    def remove(sql)
      return sql if @strategy == :none

      state = init_state
      result = []
      i = 0

      i = process_character(sql, i, result, state) while i < sql.length

      result.join
    end

    private

    def init_state
      {
        in_single: false,       # Inside '...'
        in_double: false,       # Inside "..."
        in_dollar: false,       # Inside $$...$$ or $tag$...$tag$
        dollar_tag: nil,        # Current dollar quote tag
        in_line_comment: false, # Inside -- comment
        in_block_comment: false, # Inside /* */ comment
        escape_next: false # Next char is escaped (for backslash escapes)
      }
    end

    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize
    def process_character(sql, index, result, state)
      char = sql[index]
      next_char = index + 1 < sql.length ? sql[index + 1] : nil

      # Handle escape sequences
      if state[:escape_next]
        result << char unless in_comment?(state)
        state[:escape_next] = false
        return index + 1
      end

      # Check for backslash escape
      if char == '\\' && (state[:in_single] || state[:in_double])
        result << char unless in_comment?(state)
        state[:escape_next] = true
        return index + 1
      end

      # If in comment, check for comment end
      if state[:in_line_comment]
        if char == "\n"
          state[:in_line_comment] = false
          result << char # Preserve newline
        end
        # Skip comment content
        return index + 1
      end

      if state[:in_block_comment]
        if char == '*' && next_char == '/'
          state[:in_block_comment] = false
          return index + 2 # Skip */
        end
        # Skip comment content
        return index + 1
      end

      # Not in comment - check for comment start (only if not in quotes)
      unless in_quote?(state)
        if char == '-' && next_char == '-' && should_remove_oneline?
          state[:in_line_comment] = true
          return index + 2 # Skip --
        end

        if char == '/' && next_char == '*' && should_remove_multiline?
          state[:in_block_comment] = true
          return index + 2 # Skip /*
        end
      end

      # Handle quotes
      if char == "'" && !state[:in_double] && !state[:in_dollar]
        if state[:in_single] && next_char == "'"
          # Escaped single quote (SQL style: '')
          result << char << next_char
          return index + 2
        else
          state[:in_single] = !state[:in_single]
          result << char
          return index + 1
        end
      end

      if char == '"' && !state[:in_single] && !state[:in_dollar]
        if state[:in_double] && next_char == '"'
          # Escaped double quote
          result << char << next_char
          return index + 2
        else
          state[:in_double] = !state[:in_double]
          result << char
          return index + 1
        end
      end

      # Handle dollar quotes (PostgreSQL)
      if char == '$' && !state[:in_single] && !state[:in_double]
        tag, tag_length = extract_dollar_tag(sql, index)
        if tag
          if state[:in_dollar] && tag == state[:dollar_tag]
            # Closing dollar quote
            state[:in_dollar] = false
            state[:dollar_tag] = nil
            tag_length.times { |i| result << sql[index + i] }
            return index + tag_length
          elsif !state[:in_dollar]
            # Opening dollar quote
            state[:in_dollar] = true
            state[:dollar_tag] = tag
            tag_length.times { |i| result << sql[index + i] }
            return index + tag_length
          end
        end
      end

      # Regular character
      result << char
      index + 1
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/AbcSize

    def in_quote?(state)
      state[:in_single] || state[:in_double] || state[:in_dollar]
    end

    def in_comment?(state)
      state[:in_line_comment] || state[:in_block_comment]
    end

    def should_remove_oneline?
      @strategy == :oneline || @strategy == :all
    end

    def should_remove_multiline?
      @strategy == :multiline || @strategy == :all
    end

    # Extracts dollar quote tag from position
    # Returns [tag, length] or [nil, nil]
    # Matches: $$ or $tag$ where tag is alphanumeric/underscore
    # rubocop:disable Metrics/MethodLength
    def extract_dollar_tag(sql, index)
      return [nil, nil] unless sql[index] == '$'

      # Look for closing $
      i = index + 1
      tag_chars = []

      while i < sql.length
        char = sql[i]
        if char == '$'
          # Found closing $
          tag = tag_chars.empty? ? '' : tag_chars.join
          length = i - index + 1
          return [tag, length]
        elsif char =~ /[a-zA-Z0-9_]/
          tag_chars << char
          i += 1
        else
          # Invalid character for dollar quote tag
          return [nil, nil]
        end
      end

      # No closing $ found
      [nil, nil]
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ClassLength
end
