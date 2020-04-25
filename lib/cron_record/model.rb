require 'cron_record/model_class_methods'

module CronRecord
  class Model
    extend CronRecord::ModelClassMethods

    def initialize(hour:, day:, month:, day_of_week:)
      # cron_parts[0] is minute which we dont use
      @hour         = hour
      @day          = day
      @month        = month
      @day_of_week  = day_of_week
    end

    attr_reader :hour, :day, :month, :day_of_week

    def match?(at)
      target = self.class.parse_time(at)
      (target[1] & @hour.to_bit) > 0 &&
        (target[2] & @day.to_bit) > 0 &&
        (target[3] & @month.to_bit) > 0 &&
        (target[4] & @day_of_week.to_bit) > 0
    end

    def to_attributes
      {
        hour:         hour.to_bit,
        day:          day.to_bit,
        month:        month.to_bit,
        day_of_week:  day_of_week.to_bit,
      }
    end

    def to_bits
      [
        0,
        hour.to_bit,
        day.to_bit,
        month.to_bit,
        day_of_week.to_bit
      ]
    end

    def to_s
      "0 #{hour.to_s} #{day.to_s} #{month.to_s} #{day_of_week.to_s}"
    end
  end
end
