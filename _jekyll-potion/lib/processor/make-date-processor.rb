module Jekyll::Potion
  class MakeDateProcessor < Processor
    def site_post_read(site)
      config.markdown_pages.each { |page|
        page.data["created-date"] = File.birthtime(page.path) if File.method_defined? :birthtime
        page.data["last-modified-date"] = File.mtime(page.path) if File.method_defined? :mtime
        logger.trace("make date", page.name)
      }
    end
  end
end