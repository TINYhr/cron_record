module CronRecord
  module CronableClassMethods
    def cron_execute_at(time_at)
      parsed = parse_time(time_at)

      where("(#{cron_attribute_name}_hour & ?) > 0", parsed[1])
        .where("(#{cron_attribute_name}_day & ?) > 0", parsed[2])
        .where("(#{cron_attribute_name}_month & ?) > 0", parsed[3])
        .where("(#{cron_attribute_name}_day_of_week & ?) > 0", parsed[4])
    end

    private

    def parse_time(at)
      [
        0, # Minute
        BIT_CONVERT[at.hour],
        BIT_CONVERT[at.day],
        BIT_CONVERT[at.month],
        BIT_CONVERT[at.wday]
      ]
    end
  end

  module Cronable
    def self.included(base)
      base.extend(CronRecord::CronableClassMethods)
    end

    define_method("#{cron_attribute_name}=") do |value|
      @cron_item ||= CronRecord::Model.from_cron_string(value)
      attributes.merge(@cron_item.to_bits.transform_keys { |k| "#{cron_attribute_name}_#{k}" })
      value
    end

    define_method("#{cron_attribute_name}") do
      bit_fields = [
        0,
        attributes["#{cron_attribute_name}_hour"],
        attributes["#{cron_attribute_name}_day"],
        attributes["#{cron_attribute_name}_month"],
        attributes["#{cron_attribute_name}_day_of_week"]
      ]

      @cron_item ||= CronRecord::Model.from_bit_fields(bit_fields)
      @cron_item.to_s
    end
  end
end
