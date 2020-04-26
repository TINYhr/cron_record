class MockModel1 < ActiveRecord::Base
  extend CronRecord::Cronable
  cronable :cron
end

RSpec.describe CronRecord::Cronable do
  before { DatabaseCleaner.clean }
  after { DatabaseCleaner.clean }

  describe 'integrate with ActiveRecord' do
    it 'has accessor' do
      host = MockModel1.new
      expect(host).to be
      expect(host.cron).to eq(nil)

      host.cron = '0 0 1 1 *'
      expect(host.cron).to eq('0 0 1 1 *')

      expect(host.save).to eq(true)
      expect(MockModel1.first).to eq(host)
    end
  end

  describe '.query_by_time' do
    let(:test_time) { Time.new(2020, 1, 1, 0, 0, 0) }
    it 'queried by time' do
      MockModel1.create!(cron: '0 0 1 1 *')
      MockModel1.create!(cron: '0 0 2 1 *')

      items = MockModel1.cron_execute_at(test_time).all
      expect(items.size).to eq(1)
      expect(items[0].cron).to eq('0 0 1 1 *')
    end
  end
end
