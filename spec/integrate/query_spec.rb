require 'fugit'

module QueryTest
  class MockModel1 < ActiveRecord::Base
    extend CronRecord::Cronable
    cronable :cron
  end
end
