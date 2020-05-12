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
            all_day = BIT_CONVERT[32] - 2 # start from 1
            all_day_of_week = BIT_CONVERT[7] - 1 # start from 0
            cron_attr = class_variable_get(:@@cron_attribute_name)

            # query = <<~SQL
            #   (BIT_COUNT(hour & :hour) + BIT_COUNT(month & :month) = 2) AND
            #   (
            #     (
            #       day <> #{all_day} AND
            #       day_of_week <> #{all_day_of_week} AND
            #       (BIT_COUNT(day & :day) + BIT_COUNT(day_of_week & :day_of_week) >= 1)
            #     ) OR
            #     (
            #       BIT_COUNT(day & :day) + BIT_COUNT(day_of_week & :day_of_week) = 2
            #     )
            #   )
            # SQL
            query = <<~SQL
              ((#{cron_attr}_hour & :hour >= 1) AND (#{cron_attr}_month & :month >= 1)) AND
              (
                (
                  #{cron_attr}_day <> #{all_day} AND
                  #{cron_attr}_day_of_week <> #{all_day_of_week} AND
                  ((#{cron_attr}_day & :day >= 1) OR (#{cron_attr}_day_of_week & :day_of_week >= 1))
                ) OR
                (
                  (#{cron_attr}_day & :day >= 1) AND (#{cron_attr}_day_of_week & :day_of_week >= 1)
                )
              )
            SQL

            where(query,
                  hour: CronRecord::BIT_CONVERT[time_at.hour],
                  day: CronRecord::BIT_CONVERT[time_at.day],
                  month: CronRecord::BIT_CONVERT[time_at.month],
                  day_of_week: CronRecord::BIT_CONVERT[time_at.wday])
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
