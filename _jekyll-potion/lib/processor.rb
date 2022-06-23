module Jekyll::Potion
  class Processor
    attr_accessor :config
    attr_accessor :logger

    def initialize(config)
      @config = config
      @logger = Logger.new(self)
    end

    def site_pre_render(site) end

    def site_post_read(site) end

    def site_post_render(site) end

    def page_pre_render(page) end

    def page_post_render(page) end

    def self.load_processor_class(processor_name)
      require_relative "processor/#{processor_name}.rb"

      constants = Jekyll::Potion.constants.select { |c|
        c.downcase.to_s == processor_name.to_s.gsub(/-/, "").downcase
      }

      raise SyntaxError, "undefined #{processor_name} class" if constants.empty?
      raise SyntaxError, "duplicate #{processor_name} class" if constants.size > 1

      Logger.trace(name, "load processor", processor_name)

      Jekyll::Potion.const_get(constants.first)
    end
  end
end