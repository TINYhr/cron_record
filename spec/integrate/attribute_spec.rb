require 'fugit'

module AttributeTest
  class MockModel1 < ActiveRecord::Base
    extend CronRecord::Cronable
    cronable :cron
  end
end
