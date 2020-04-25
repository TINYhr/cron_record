require 'cron_record/item'

module CronRecord
  module ModelClassMethods
    def query_by_time(at = Time.current)
      parsed = parse_time(at)

      where("(cron_hour & ?) > 0", parsed[1])
        .where("(cron_day & ?) > 0", parsed[2])
        .where("(cron_month & ?) > 0", parsed[3])
        .where("(cron_day_of_week & ?) > 0", parsed[4])
    end

    def parse_time(at)
      [
        0, # Minute
        BIT_CONVERT[at.hour],
        BIT_CONVERT[at.day],
        BIT_CONVERT[at.month],
        BIT_CONVERT[at.wday]
      ]
    end

    def from_bit_fields(bit_fields)
      if bit_fields.size != 5
        raise StandardError('Unsupport bit_fields length')
      end

      new(
        # minute:       Hour.from_bits(bit_fields[0]), # Not support yet
        hour:         Hour.from_bits(bit_fields[1]),
        day:          Day.from_bits(bit_fields[2]),
        month:        Month.from_bits(bit_fields[3]),
        day_of_week:  DayOfWeek.from_bits(bit_fields[4]),
      )
    end

    def from_cron_string(cron_str)
      cron_parts = cron_str.split(' ').compact

      new(
        # minute:       Minute.new(cron_parts[0]) # Not support yet
        hour:         Hour.from_str(cron_parts[1]),
        day:          Day.from_str(cron_parts[2]),
        month:        Month.from_str(cron_parts[3]),
        day_of_week:  DayOfWeek.from_str(cron_parts[4]),
      )
    end
  end
end
