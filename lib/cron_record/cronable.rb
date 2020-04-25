module CronRecord
  module Cronable
    def cronable(attr_name, **options)
      CronRecord.models << self

      class_eval do
        class_variable_set :@@cron_attribute_name, attr_name

        class << self
          def cron_execute_at(time_at)
            parsed = [
              0, # Minute
              CronRecord::BIT_CONVERT[time_at.hour],
              CronRecord::BIT_CONVERT[time_at.day],
              CronRecord::BIT_CONVERT[time_at.month],
              CronRecord::BIT_CONVERT[time_at.wday]
            ]

            where("(#{class_variable_get(:@@cron_attribute_name)}_hour & ?) > 0", parsed[1])
              .where("(#{class_variable_get(:@@cron_attribute_name)}_day & ?) > 0", parsed[2])
              .where("(#{class_variable_get(:@@cron_attribute_name)}_month & ?) > 0", parsed[3])
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
      end
    end
  end
end
