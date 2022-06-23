module Jekyll::Potion
  class EmptyContentProcessor < Processor
    def initialize(config)
      super
      @template = config.load_processor_template("empty-content")
    end

    def page_pre_render(page)
      if config.show_empty? && config.markdown_converter.matches(page.extname) && config.page_potion(page).empty_content?
        config.page_potion(page).render_for_empty(@template)
      end
    end
  end
end
