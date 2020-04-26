require "bundler/setup"
require "cron_record"

# Test & integrate gems
require 'active_record'
require 'database_cleaner/active_record'
DatabaseCleaner.strategy = :truncation
require 'pry-byebug'
require 'fugit'

module CronRecordTestHelper
  HOURS         = (0..23).to_a + ['*']
  DAYS          = (1..31).to_a + ['*']
  MONTHS        = (1..12).to_a + ['*']
  DAYS_OF_WEEK  = (0..6).to_a + ['*']

  def self.random
    "0 #{HOURS.sample} #{DAYS.sample} #{MONTHS.sample} #{DAYS_OF_WEEK.sample}"
  end

  def self.all
    DAYS_OF_WEEK.each do |day_of_week|
      MONTHS.each do |month|
        DAYS.each do |day|
          if month != '*' && day != '*'
            if (month == 2 && day > 29)
              next
            end
            if [4, 6, 9, 11].include?(month) && day > 30
              next
            end
          end

          HOURS.each do |hour|
            yield("0 #{hour} #{day} #{month} #{day_of_week}")
          end
        end
      end
    end
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

ActiveRecord::Base.establish_connection(
  adapter:  "sqlite3",
  database: 'spec/db/cron_test.sqlite3',
  pool: 5,
  timeout: 5000,
)
ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS mock_model1s;')
ActiveRecord::Base.connection.execute(<<~SQL)
  CREATE TABLE mock_model1s (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    cron_hour         BIGINT NOT NULL,
    cron_day          BIGINT NOT NULL,
    cron_month        BIGINT NOT NULL,
    cron_day_of_week  BIGINT NOT NULL
  );
SQL
