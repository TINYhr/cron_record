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
      # TODO: [AV] !!! Need reflect to query
      if !@day.is_all? && !@day_of_week.is_all?
        ((BIT_CONVERT[at.hour] & @hour.to_bit) > 0 &&
                  (BIT_CONVERT[at.day] & @day.to_bit) > 0 &&
                  (BIT_CONVERT[at.month] & @month.to_bit) > 0) ||
        ((BIT_CONVERT[at.hour] & @hour.to_bit) > 0 &&
                  (BIT_CONVERT[at.month] & @month.to_bit) > 0 &&
                  (BIT_CONVERT[at.wday] & @day_of_week.to_bit) > 0)
      else
        (BIT_CONVERT[at.hour] & @hour.to_bit) > 0 &&
          (BIT_CONVERT[at.day] & @day.to_bit) > 0 &&
          (BIT_CONVERT[at.month] & @month.to_bit) > 0 &&
          (BIT_CONVERT[at.wday] & @day_of_week.to_bit) > 0
      end
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
