module Jekyll::Potion
  class Config < Liquid::Drop
    CONFIG_KEY = "jekyll-potion"

    PRIORITY = 10

    TITLE_KEY = "title"
    ICON_KEY = "icon"
    THEME_KEY = "theme"
    ASSETS_PATH_KEY = "assets"
    IS_SHOW_PAGINATION_KEY = "is_show_pagination"
    IS_SHOW_EMPTY_KEY = "is_show_empty"
    FAVICON_KEY = "favicon"
    FAVICON_PATH_KEY = "path"
    FAVICON_ASSETS_KEY = "assets"
    PROCESSOR_KEY = "processors"

    DEFAULT = {
      TITLE_KEY => "",
      ICON_KEY => "",
      THEME_KEY => "proto",
      ASSETS_PATH_KEY => "assets",
      IS_SHOW_PAGINATION_KEY => true,
      IS_SHOW_EMPTY_KEY => true,
      FAVICON_KEY => {
        FAVICON_PATH_KEY => "",
        FAVICON_ASSETS_KEY => ""
      },
      PROCESSOR_KEY => [
        "optional-front-matter-processor",
        "static-files-processor",
        "make-title-processor",
        "make-date-processor",
        "navigation-processor",
        "empty-content-processor",
        "pagination-processor",
        "rewrite-img-src-processor",
        "rewrite-a-href-processor",
        "search-processor"
      ]
    }

    POTION_KEY = "potion"

    ALL_PAGES_KEY = "all_pages"

    @config = {}
    @processors = []

    def site_after_init(site)
      @base_path = File.dirname(__FILE__)
      @base_path["#{Dir.pwd}/"] = ""

      @site = site
      @config = merge(DEFAULT, site.config[CONFIG_KEY])

      @processors = @config[PROCESSOR_KEY].map { |processor| Processor.load_processor_class(processor) }
                                          .map { |processor_class| processor_class.new(self) }

      @assets_collection = Jekyll::Collection.new(@site, assets_path)
    end

    def merge(default, config)
      merged = {}

      unless config.nil?
        default.each do |k, v|
          if v.instance_of? Hash
            merged[k] = self.merge(v, config[k])
          else
            merged[k] = config[k] ||= v
          end
        end
      end
      merged
    end

    def site_pre_render(site)
      @processors.each { |processor| processor.site_pre_render(site) }
    end

    def site_post_render(site)
      @processors.each { |processor| processor.site_post_render(site) }
    end

    def site_post_read(site)
      @processors.each { |processor| processor.site_post_read(site) }
    end

    def page_pre_render(page)
      @processors.each { |processor| processor.page_pre_render(page) }
    end

    def page_post_render(page)
      @processors.each { |processor| processor.page_post_render(page) }
    end

    def baseurl
      @site.config["baseurl"] ||= ""
    end

    def theme_path
      File.join(@base_path, "theme", @config[THEME_KEY])
    end

    def _includes
      File.join(theme_path, "_includes")
    end

    def _sass
      File.join(theme_path, "_sass")
    end

    def assets
      File.join(theme_path, "assets")
    end

    def assets_path
      @config[ASSETS_PATH_KEY]
    end

    def target_assets
      File.join(baseurl, assets_path)
    end

    def site_title
      @config[TITLE_KEY]
    end

    def site_icon
      if @config[ICON_KEY].empty?
        @config[ICON_KEY]
      else
        File.join(baseurl, @config[ICON_KEY])
      end
    end

    def favicon_path
      @config[FAVICON_KEY][FAVICON_PATH_KEY]
    end

    def favicon_assets
      File.join(baseurl, @config[FAVICON_KEY][FAVICON_ASSETS_KEY])
    end

    def templates_path
      File.join(theme_path, "template")
    end

    def processor_templates
      File.join(templates_path, "processor")
    end

    def tags_templates
      File.join(templates_path, "tags")
    end

    def make_site_potion
      make_site_data(POTION_KEY, self)
    end

    def make_site_data(key, value)
      @site.data[key] = value
    end

    def static_files
      @site.static_files
    end

    def make_page(base, dir, name)
      Jekyll::Page.new(@site, base, dir, name)
    end

    def add_static_files(base, dir, name)
      @site.static_files << Jekyll::StaticFile.new(@site, base, dir, name, @assets_collection)
    end

    def markdown_converter
      @site.find_converter_instance(Jekyll::Converters::Markdown)
    end

    def markdown_pages
      @site.pages.select { |page| markdown_converter.matches(page.extname) }
    end

    def static_markdown_files
      @site.static_files.select { |file| markdown_converter.matches(file.extname) }
    end

    def load_processor_template(template_name)
      load_template(processor_templates, template_name)
    end

    def load_tags_template(template_name)
      load_template(tags_templates, template_name)
    end

    def load_template(path, template_name)
      Liquid::Template.parse(File.read([File.join(path, template_name), ".liquid"].join))
    end

    def site_potion
      @site.data[POTION_KEY]
    end

    def page_potion(page)
      page.data[POTION_KEY]
    end

    def show_pagination?
      @config[IS_SHOW_PAGINATION_KEY]
    end

    def show_empty?
      @config[IS_SHOW_EMPTY_KEY]
    end

    def self.load_config
      config = Config.new

      Jekyll::Hooks.register_one(:site, :after_init, PRIORITY) do |site|
        config.site_after_init(site)
      end

      Jekyll::Hooks.register_one(:site, :post_read, PRIORITY) do |site|
        config.make_site_potion
        Logger.trace(Config.class.name, "make site potion")
        config.site_post_read(site)
      end

      Jekyll::Hooks.register_one(:site, :pre_render, PRIORITY) do |site|
        config.site_pre_render(site)
      end

      Jekyll::Hooks.register_one(:site, :post_render, PRIORITY) do |site|
        config.site_post_render(site)
      end

      Jekyll::Hooks.register_one(:pages, :pre_render, PRIORITY) do |page|
        config.page_pre_render(page)
      end

      Jekyll::Hooks.register_one(:pages, :post_render, PRIORITY) do |page|
        config.page_post_render(page)
      end
    end
  end
end
