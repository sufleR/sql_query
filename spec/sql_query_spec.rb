# frozen_string_literal: true

require 'spec_helper'

describe SqlQuery do
  let(:options) { { email: 'e@mail.dev' } }
  let(:file_name) { :get_player_by_email }
  let(:query) { described_class.new(file_name, options) }

  class Model < ActiveRecord::Base
    self.abstract_class = true
  end

  describe '#initialize' do
    it 'sets instance variables for all options' do
      expect(query.instance_variable_get(:@email)).to eq 'e@mail.dev'
    end

    context 'when options are set not in parentheses' do
      let(:query) { described_class.new(file_name, email: 'e@mail.dev') }

      it 'sets instance variables for all options' do
        expect(query.instance_variable_get(:@email)).to eq 'e@mail.dev'
      end
    end

    context 'when file_name argument is not Symbol or String' do
      let(:file_name) { { do: 'something' } }

      it 'raises ArgumentError' do
        expect { query }
          .to raise_error(ArgumentError,
                          'SQL file name should be String or Symbol')
      end
    end

    context 'with db_connection option' do
      let(:options) { { db_connection: Model.connection } }

      it 'sets connection to requested' do
        expect(query.connection).to eq(Model.connection)
      end
    end
  end

  describe '#file_path' do
    context 'when there is only one file with name' do
      it 'returns path to it' do
        expect(query.send(:file_path)).to include('get_player_by_email.sql.erb')
      end
    end
    context 'when there are no files' do
      let(:file_name) { :not_exists }

      it 'raises error' do
        expect { query.send(:file_path) }
          .to raise_error('File not found: not_exists')
      end
    end

    context 'when there are more than one matching files' do
      let(:file_name) { :duplicated }

      it 'raises error' do
        expect { query.send(:file_path) }
          .to raise_error.with_message(/More than one file found:/)
      end
    end
  end

  describe '#path' do
    context 'when there is sql_file_path option' do
      let(:options) { { sql_file_path: '/path_to_file' } }
      let(:file_name) { 'fname' }

      it 'sets it as dir for file' do
        expect(query.send(:path)).to eq('/path_to_file/fname.{sql.erb,erb.sql}')
      end
    end
  end

  describe '#sql' do
    it 'returns query string' do
      expect(query.sql)
        .to eq("SELECT *\nFROM players\nWHERE email = 'e@mail.dev'\n")
    end

    context 'when file is .erb.sql' do
      let(:options) { { fake: 12 } }
      let(:file_name) { :erb_sql }

      it 'returns query string' do
        expect(query.sql).to eq "SELECT 12\n"
      end
    end
  end

  describe '#pretty_sql' do
    it 'returns query string' do
      expect(query.pretty_sql)
        .to eq("SELECT *\nFROM players\nWHERE email = 'e@mail.dev'\n")
    end
  end

  describe '#explain' do
    let(:explain) { query.explain }
    it 'returns explain string' do
      expect(explain).to include 'EXPLAIN for:'
      expect(explain).to include 'FROM players'
      expect(explain).to include "WHERE email = 'e@mail.dev'"
      expect(explain).to include 'QUERY PLAN'
      expect(explain).to include 'Seq Scan on players'
    end
  end

  describe '#execute' do
    before do
      ActiveRecord::Base.connection.execute(
        "INSERT INTO players (email) VALUES ('e@mail.dev')"
      )
    end

    after do
      ActiveRecord::Base.connection.execute(
        'DELETE FROM players'
      )
    end

    it 'returns data from database' do
      expect(query.execute).to eq [{ 'email' => 'e@mail.dev' }]
    end

    context 'when prepare argument is true' do
      it 'executes prepared query for logs' do
        expect(query).to receive(:prepared_for_logs) { '' }
        query.execute
      end
    end

    context 'when prepare argument is false' do
      it 'executes unchanged sql query' do
        expect(query).not_to receive(:prepared_for_logs)
        query.execute(false)
      end
    end
  end

  describe '#partial' do
    let(:file_name) { :get_player_by_email_with_template }
    it 'resolves partials as parts of sql queries' do
      expect(query.sql)
        .to eq("SELECT *\nFROM players\nWHERE players.email = 'e@mail.dev'\n\n")
    end

    context 'when partial name is string with file path' do
      let(:file_name) { :get_player_by_email }

      it 'should find file by whole path and _name' do
        query
        expect(described_class)
          .to receive(:new).with('some/path/to/_file.sql', options) { query }
        query.partial('some/path/to/file.sql', {})
      end
    end
  end

  describe '#prepared_for_logs' do
    it 'returns string without new lines' do
      expect(query.prepared_for_logs)
        .to eq("SELECT * FROM players WHERE email = 'e@mail.dev' ")
    end
  end

  describe '.config' do
    it 'returns configuration instance' do
      expect(described_class.config).to be_kind_of(SqlQuery::Config)
    end
  end
end
