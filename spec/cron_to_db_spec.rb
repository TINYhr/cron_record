require 'fugit'

class MockModel1 < ActiveRecord::Base
  extend CronRecord::Cronable
  cronable :cron
end

RSpec.describe 'Cron to DB' do
  it "convert cron string to bit fields" do
    cron = CronRecord::Model.from_cron_string('0 0 1 1 *')
    expect(cron.to_bits).to eq([0,1,2,2,127])
    expect(cron.to_s).to eq('0 0 1 1 *')
  end

  it "convert cron bit fields to string" do
    cron = CronRecord::Model.from_bit_fields([0,1,2,2,127])
    expect(cron.to_bits).to eq([0,1,2,2,127])
    expect(cron.to_s).to eq('0 0 1 1 *')
  end

  describe 'match? function' do
    context 'Unmatched' do
      let(:test_time) { Time.new(2020, 2, 1, 0, 0, 0) }
      let(:cron_str) { '0 0 1 1 *' }

      it 'match with fugit' do
        cron = CronRecord::Model.from_cron_string(cron_str)
        fu = Fugit.parse(cron_str)

        expect(cron.match?(test_time)).to eq(false)
        expect(fu.match?(test_time)).to eq(false)
      end
    end

    context 'Matched' do
      let(:test_time) { Time.new(2020, 1, 1, 0, 0, 0) }
      let(:cron_str) { '0 0 1 1 *' }

      it 'match with fugit' do
        cron = CronRecord::Model.from_cron_string(cron_str)
        fu = Fugit.parse(cron_str)

        expect(cron.match?(test_time)).to eq(true)
        expect(fu.match?(test_time)).to eq(true)
      end
    end
  end

  describe 'integrate with ActiveRecord' do
    it 'has accessor' do
      host = MockModel1.new
      expect(host).to be
      expect(host.cron).to eq(nil)

      host.cron = '0 0 1 1 *'

      expect(host.cron).to eq('0 0 1 1 *')
    end

    it 'queried by time' do
      pending('Implement !!!')
    end
  end
end
