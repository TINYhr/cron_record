require "bundler/setup"
require "cron_record"

require 'pry-byebug' if ENV['DEBUG'] == '1'

module CronRecordTestHelper
  HOURS         = (0..23).to_a + ['*']
  DAYS          = (1..31).to_a + ['*']
  MONTHS        = (0..11).to_a + ['*']
  DAYS_OF_WEEK  = (0..6).to_a + ['*']

  def self.random
    "0 #{HOURS.sample} #{DAYS.sample} #{MONTHS.sample} #{DAYS_OF_WEEK.sample}"
  end

  def self.sql_generator
    <<~SQL
      DELIMITER ;
      DROP PROCEDURE IF EXISTS doiterate;
      CREATE PROCEDURE doiterate(p1 INT)
      BEGIN
        label1: LOOP
          INSERT INTO `cron_record_no_index` (`hour`, `day`, `month`, `day_of_week`) VALUES (FLOOR(RAND()*16777215 + 1), FLOOR(RAND()*2147483646 + 2), FLOOR(RAND()*2047 + 1), FLOOR(RAND()*127 + 1)) ;
          SET p1 = p1 + 1 ;
          IF p1 < 1000 THEN
            ITERATE label1 ;
          END IF;
          LEAVE label1;
        END LOOP label1;
      END;

      call doiterate(0);

      DROP PROCEDURE IF EXISTS doiterate;
    SQL
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
