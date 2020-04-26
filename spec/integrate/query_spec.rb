module QueryTest
  class MockModel1 < ActiveRecord::Base
    self.table_name = 'mock_model1s'

    extend CronRecord::Cronable
    cronable :cron
  end
end

RSpec.describe 'Query cron' do
end
