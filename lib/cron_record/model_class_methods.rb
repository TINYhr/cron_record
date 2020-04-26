require 'cron_record/item'

module CronRecord
  module ModelClassMethods
    def from_bit_fields(bit_fields)
      if bit_fields.size != 5
        raise CronRecord::Error('Unsupport bit_fields length')
      end

      new(
        # minute:       CronRecord::Minute.from_bits(bit_fields[0]), # Not support yet
        hour:         CronRecord::Hour.from_bits(bit_fields[1]),
        day:          CronRecord::Day.from_bits(bit_fields[2]),
        month:        CronRecord::Month.from_bits(bit_fields[3]),
        day_of_week:  CronRecord::DayOfWeek.from_bits(bit_fields[4]),
      )
    end

    def from_cron_string(cron_str)
      cron_parts = cron_str.split(' ').compact

      new(
        # minute:       CronRecord::Minute.new(cron_parts[0]) # Not support yet
        hour:         CronRecord::Hour.from_str(cron_parts[1]),
        day:          CronRecord::Day.from_str(cron_parts[2]),
        month:        CronRecord::Month.from_str(cron_parts[3]),
        day_of_week:  CronRecord::DayOfWeek.from_str(cron_parts[4]),
      )
    end
  end
end
