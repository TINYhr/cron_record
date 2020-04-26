module CronRecord
  class Item
    class << self
      def from_str(item_str)
        data = if item_str == '*'
          self.range.to_a
        else
          item_str.split(',').map do |value|
            Integer(value.strip).tap do |value_i|
              raise StandardError.new("Invalid #{self.name} value: [#{value_i}]") unless self.range.include?(value_i)
            end
          end
        end

        new(data)
      end

      def from_bits(item_bits)
        item_bits = Integer(item_bits)
        if item_bits <= 0
          raise StandardError.new("Invalid #{self.name} value: #{item_bits}")
        end

        i = 0
        data = []
        while item_bits > 0
          if item_bits % 2 == 1
            data << i
          end

          item_bits = item_bits >> 1
          i += 1
        end

        invalid_items = data - self.range.to_a
        if invalid_items.size > 0
          raise StandardError.new("Invalid #{self.name} value: #{invalid_items}")
        end


        new(data)
      end

      def range
        raise NotImplemented
      end
    end

    def initialize(cron_item)
      @cron_item = cron_item.uniq.sort
    end

    def to_bit
      @cron_item.sum do |value|
        BIT_CONVERT[value]
      end
    end

    def to_s
      if @cron_item.size == self.class.range.size
        '*'
      else
        @cron_item.join(',')
      end
    end
  end

  class Hour < Item
    def self.range
      (0..23)
    end
  end

  class Day < Item
    def self.range
      (1..31)
    end
  end

  class Month < Item
    def self.range
      (1..12)
    end
  end

  class DayOfWeek < Item
    def self.range
      (0..6)
    end
  end
end
