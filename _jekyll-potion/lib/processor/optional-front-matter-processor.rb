module Jekyll::Potion
  class OptionalFrontMatterProcessor < Processor
    def site_post_read(site)
      site.pages.concat(static_files_to_pages)
      site.static_files -= config.static_markdown_files
    end

    def static_files_to_pages
      config.static_markdown_files.map do |markdown_page|
        base = markdown_page.instance_variable_get("@base")
        dir = markdown_page.instance_variable_get("@dir")
        name = markdown_page.instance_variable_get("@name")

        page = config.make_page(base, dir, name)

        logger.trace("make to site page", name)
        page
      end
    end
  end
end