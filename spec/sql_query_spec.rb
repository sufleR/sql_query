require 'spec_helper'

describe SqlQuery do

  let(:base_options) { { sql_name: :get_player_by_email, email: 'e@mail.dev' } }
  let(:options) { base_options }
  let(:query) { described_class.new(options) }

  describe '#sql' do
    it 'returns query string' do
      expect(query.sql).to eq "SELECT *\nFROM players\nWHERE email = 'e@mail.dev'\n"
    end
  end

  describe '#pretty_sql' do
    it 'returns query string' do
      expect(query.pretty_sql).to eq "SELECT *\nFROM players\nWHERE email = 'e@mail.dev'\n"
    end
  end

  describe '#explain' do
    let(:explain) { query.explain }
    it 'returns explain string' do
      expect(explain).to include 'EXPLAIN for:'
      expect(explain).to include "FROM players"
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
        "DELETE FROM players"
      )
    end

    it 'returns data from database' do
      expect(query.execute).to eq [{ 'email' => 'e@mail.dev'}]
    end
  end
end
