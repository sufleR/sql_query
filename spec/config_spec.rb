# frozen_string_literal: true

require 'spec_helper'

describe SqlQuery::Config do
  describe 'initialize' do
    it 'sets path to default' do
      expect(described_class.new.path).to eq('/app/sql_queries')
    end

    it 'sets adapter to ActiveRecord::Base' do
      expect(described_class.new.adapter).to eq(ActiveRecord::Base)
    end
  end
end
