module AttributeTest
  class MockModel1 < ActiveRecord::Base
    self.table_name = 'mock_model1s'

    extend CronRecord::Cronable
    cronable :cron
  end
end

RSpec.describe 'Cron model attribute accessor', verbose: true do
  before(:all) { DatabaseCleaner.clean }
  after(:all) { DatabaseCleaner.clean }

  describe 'Create cron' do
    CronRecordTestHelper.all do |cron|
      it "create cron [#{cron}]" do
        subject = AttributeTest::MockModel1.create!(cron: cron)
        expect(subject).to be_persisted

        fugit = Fugit::Cron.parse("#{cron} UTC")
        expect(subject.cron_match?(fugit.next_time.utc)).to eq(true)

        between_date = fugit.previous_time + ((fugit.next_time - fugit.previous_time) / 2)
        # Eliminate minute difference in hourly, next_time and previous_time are continuously
        between_date = Time.new(
          between_date.year,
          between_date.month,
          between_date.day,
          between_date.hour,
          0,
          0).utc
        expect(subject.cron_match?(between_date)).to eq(fugit.match?(between_date))
      end
    end
  end

  describe 'Query cron' do
    AttributeTest::MockModel1.find_each do |subject|
      describe "query cron [#{subject.cron}]" do
        fugit = Fugit::Cron.parse("#{subject.cron} UTC")
        expect(AttributeTest::MockModel1.cron_execute_at(fugit.next_time).where(id: subject.id).exists?).to eq(true)
      end
    end
  end
end
