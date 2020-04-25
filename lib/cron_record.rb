require "cron_record/version"

module CronRecord
  class Error < StandardError; end

  class << self
    attr_accessor :models
  end

  self.models = []
end

require "cron_record/const"
require "cron_record/item"
require "cron_record/model"
require "cron_record/cronable"
