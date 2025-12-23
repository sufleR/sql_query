# frozen_string_literal: true

require 'spec_helper'

describe SqlQuery::Config do
  let(:config) { described_class.new }

  describe 'initialize' do
    it 'sets path to default' do
      expect(config.path).to eq('/app/sql_queries')
    end

    it 'sets adapter to ActiveRecord::Base' do
      expect(config.adapter).to eq(ActiveRecord::Base)
    end

    it 'sets remove_comments to :all by default' do
      expect(config.remove_comments).to eq(:all)
    end

    it 'sets remove_comments_from to :all by default' do
      expect(config.remove_comments_from).to eq(:all)
    end
  end

  describe '#should_comments_be_removed?' do
    context 'when remove_comments_from is :all' do
      before { config.remove_comments_from = :all }

      it 'returns true for logs' do
        expect(config.should_comments_be_removed?(for_logs: true)).to be true
      end

      it 'returns true for non-logs' do
        expect(config.should_comments_be_removed?(for_logs: false)).to be true
      end
    end

    context 'when remove_comments_from is :prepared_for_logs' do
      before { config.remove_comments_from = :prepared_for_logs }

      it 'returns true for logs' do
        expect(config.should_comments_be_removed?(for_logs: true)).to be true
      end

      it 'returns false for non-logs' do
        expect(config.should_comments_be_removed?(for_logs: false)).to be false
      end
    end

    context 'when remove_comments_from is :none' do
      before { config.remove_comments_from = :none }

      it 'returns false for logs' do
        expect(config.should_comments_be_removed?(for_logs: true)).to be false
      end

      it 'returns false for non-logs' do
        expect(config.should_comments_be_removed?(for_logs: false)).to be false
      end
    end

    context 'when remove_comments_from is an unknown value' do
      before { config.remove_comments_from = :unknown }

      it 'returns false for logs' do
        expect(config.should_comments_be_removed?(for_logs: true)).to be false
      end

      it 'returns false for non-logs' do
        expect(config.should_comments_be_removed?(for_logs: false)).to be false
      end
    end
  end
end
