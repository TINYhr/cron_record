module CronRecord
  module Cronable
    def cronable(attr_name, **options)
      CronRecord.models << self

      cron_precise = options[:precise] || :hourly
      unless SUPPORTED_PRECISIONS.include?(cron_precise)
        raise CronRecord::Error.new("Precise #{cron_precise} is not supported.")
      end

      class_eval do
        class_variable_set :@@cron_attribute_name, attr_name
        class_variable_set :@@cron_precise, cron_precise

        class << self
          def cron_execute_at(time_at)
            parsed = [
              0, # Minute
              CronRecord::BIT_CONVERT[time_at.hour],
              CronRecord::BIT_CONVERT[time_at.day],
              CronRecord::BIT_CONVERT[time_at.month],
              CronRecord::BIT_CONVERT[time_at.wday]
            ]

            # all_day = BIT_CONVERT[32] - 2 # start from 1
            # all_day_of_week = BIT_CONVERT[7] - 1 # start from 0
            # <<~SQL
            #   WHERE (BIT_COUNT(hour & $hour) + BIT_COUNT(month & $month) = 2) AND
            #   (
            #     (
            #       $day <> ALL_DAY AND
            #       $day_of_week <> ALL_DAY_OF_WEEK AND
            #       (BIT_COUNT(day & $day) + BIT_COUNT(day_of_week & $day_of_week) >= 1)
            #     ) OR
            #     (
            #       BIT_COUNT(day & $day) + BIT_COUNT(day_of_week & $day_of_week) = 2
            #     )
            #   )
            # SQL

            where("(#{class_variable_get(:@@cron_attribute_name)}_hour & ?) > 0", parsed[1])
              .where("(#{class_variable_get(:@@cron_attribute_name)}_month & ?) > 0", parsed[3])
              .where("(#{class_variable_get(:@@cron_attribute_name)}_day & ?) > 0", parsed[2])
              .where("(#{class_variable_get(:@@cron_attribute_name)}_day_of_week & ?) > 0", parsed[4])
          end
        end

        define_method("#{attr_name}=") do |value|
          @cron_item ||= CronRecord::Model.from_cron_string(value)

          assign_attributes(@cron_item.to_attributes.transform_keys { |key| "#{attr_name}_#{key}" })
          value
        end

        define_method("#{attr_name}") do
          return nil if attributes["#{attr_name}_hour"].nil? ||
                        attributes["#{attr_name}_day"].nil? ||
                        attributes["#{attr_name}_month"].nil? ||
                        attributes["#{attr_name}_day_of_week"].nil?

          bit_fields = [
            0,
            attributes["#{attr_name}_hour"],
            attributes["#{attr_name}_day"],
            attributes["#{attr_name}_month"],
            attributes["#{attr_name}_day_of_week"]
          ]

          @cron_item ||= CronRecord::Model.from_bit_fields(bit_fields)
          @cron_item.to_s
        end

        define_method("#{attr_name}_match?") do |value|
          return false if attributes["#{attr_name}_hour"].nil? ||
                        attributes["#{attr_name}_day"].nil? ||
                        attributes["#{attr_name}_month"].nil? ||
                        attributes["#{attr_name}_day_of_week"].nil?

          bit_fields = [
            0,
            attributes["#{attr_name}_hour"],
            attributes["#{attr_name}_day"],
            attributes["#{attr_name}_month"],
            attributes["#{attr_name}_day_of_week"]
          ]

          @cron_item ||= CronRecord::Model.from_bit_fields(bit_fields)
          @cron_item.match?(value)
        end
      end
    end
  end
end
