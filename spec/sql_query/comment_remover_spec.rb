# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQuery::CommentRemover do
  describe '#remove' do
    context 'with strategy :none' do
      let(:remover) { described_class.new(:none) }

      it 'returns SQL unchanged' do
        sql = "SELECT * FROM t -- comment\nWHERE id = 1"
        expect(remover.remove(sql)).to eq(sql)
      end
    end

    context 'with strategy :oneline' do
      let(:remover) { described_class.new(:oneline) }

      it 'removes single-line comments' do
        sql = "SELECT * FROM t -- comment\nWHERE id = 1"
        expected = "SELECT * FROM t \nWHERE id = 1"
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'removes comment at end of file without newline' do
        sql = 'SELECT * FROM t --comment'
        expected = 'SELECT * FROM t '
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'keeps multi-line comments' do
        sql = "SELECT * FROM t /* comment */\nWHERE id = 1"
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves -- in single-quoted strings' do
        sql = "SELECT '-- not a comment' FROM t"
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves -- in double-quoted identifiers' do
        sql = 'SELECT "column--name" FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves -- in dollar-quoted strings' do
        sql = 'SELECT $$text with -- comment$$ FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end
    end

    context 'with strategy :multiline' do
      let(:remover) { described_class.new(:multiline) }

      it 'removes multi-line comments' do
        sql = "SELECT * /* comment */ FROM t\nWHERE id = 1"
        expected = "SELECT *  FROM t\nWHERE id = 1"
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'removes multi-line comments spanning multiple lines' do
        sql = "SELECT * /* comment\nspanning lines */ FROM t"
        expected = 'SELECT *  FROM t'
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'keeps single-line comments' do
        sql = "SELECT * FROM t -- comment\nWHERE id = 1"
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves /* */ in single-quoted strings' do
        sql = "SELECT '/* not a comment */' FROM t"
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves /* */ in double-quoted identifiers' do
        sql = 'SELECT "column/* name */" FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves /* */ in dollar-quoted strings' do
        sql = 'SELECT $$text with /* comment */$$ FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end
    end

    context 'with strategy :all' do
      let(:remover) { described_class.new(:all) }

      it 'removes both single-line and multi-line comments' do
        sql = "SELECT * /* inline */ FROM t -- end\nWHERE id = 1"
        expected = "SELECT *  FROM t \nWHERE id = 1"
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'removes multiple comments of different types' do
        sql = "-- start\nSELECT /* c1 */ * /* c2 */ FROM t -- end"
        expected = "\nSELECT  *  FROM t "
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'preserves comments in all quote types' do
        sql = "SELECT '-- c1', \"-- c2\", $$-- c3$$ FROM t"
        expect(remover.remove(sql)).to eq(sql)
      end
    end

    context 'with escaped quotes' do
      let(:remover) { described_class.new(:all) }

      it 'handles SQL-style escaped single quotes' do
        sql = "SELECT 'it''s' FROM t -- comment"
        expected = "SELECT 'it''s' FROM t "
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'handles SQL-style escaped double quotes' do
        sql = 'SELECT "col""name" FROM t -- comment'
        expected = 'SELECT "col""name" FROM t '
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'handles backslash-escaped quotes' do
        sql = "SELECT 'it\\'s' FROM t -- comment"
        expected = "SELECT 'it\\'s' FROM t "
        expect(remover.remove(sql)).to eq(expected)
      end
    end

    context 'with dollar-quoted strings' do
      let(:remover) { described_class.new(:all) }

      it 'preserves comments in simple dollar quotes' do
        sql = 'SELECT $$text with -- comment$$ FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves comments in tagged dollar quotes' do
        sql = 'SELECT $tag$text with /* comment */$tag$ FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'handles multiple dollar-quoted strings' do
        sql = 'SELECT $$-- c1$$, $t$/* c2 */$t$ FROM t -- real comment'
        expected = 'SELECT $$-- c1$$, $t$/* c2 */$t$ FROM t '
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'handles nested dollar quotes with different tags' do
        sql = 'SELECT $outer$text $inner$nested$inner$$outer$ FROM t'
        expect(remover.remove(sql)).to eq(sql)
      end
    end

    context 'with inline comments' do
      let(:remover) { described_class.new(:all) }

      it 'removes inline block comments' do
        sql = 'SELECT /* comment */ column FROM t'
        expected = 'SELECT  column FROM t'
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'removes multiple inline comments' do
        sql = 'SELECT /* c1 */ col1, /* c2 */ col2 FROM t'
        expected = 'SELECT  col1,  col2 FROM t'
        expect(remover.remove(sql)).to eq(expected)
      end
    end

    context 'with comments containing quotes' do
      let(:remover) { described_class.new(:all) }

      it 'handles single-line comments with quotes' do
        sql = "SELECT * FROM t -- comment with 'quotes' and \"more\"\nWHERE id = 1"
        expected = "SELECT * FROM t \nWHERE id = 1"
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'handles multi-line comments with quotes' do
        sql = "SELECT * FROM t /* comment with 'quotes' and \"more\" */ WHERE id = 1"
        expected = 'SELECT * FROM t  WHERE id = 1'
        expect(remover.remove(sql)).to eq(expected)
      end
    end

    context 'with edge cases' do
      let(:remover) { described_class.new(:all) }

      it 'handles empty SQL' do
        expect(remover.remove('')).to eq('')
      end

      it 'handles SQL with only comments' do
        sql = "-- comment 1\n/* comment 2 */"
        expected = "\n"
        expect(remover.remove(sql)).to eq(expected)
      end

      it 'handles SQL with no comments' do
        sql = 'SELECT * FROM t WHERE id = 1'
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'handles comment-like patterns that are not comments' do
        sql = "SELECT * FROM t WHERE url = 'http://example.com' AND x = 1"
        expect(remover.remove(sql)).to eq(sql)
      end

      it 'preserves newlines from removed single-line comments' do
        sql = "SELECT *\n-- comment\nFROM t"
        expected = "SELECT *\n\nFROM t"
        expect(remover.remove(sql)).to eq(expected)
      end
    end
  end
end
