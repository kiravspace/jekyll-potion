module Jekyll::Potion
  class PaginationProcessor < Processor
    def initialize(config)
      super
      @template = config.load_processor_template("pagination")
    end

    def page_pre_render(page)
      if config.show_pagination? && config.markdown_converter.matches(page.extname)
        config.page_potion(page).render_for_pagination(@template)
      end
    end
  end
end