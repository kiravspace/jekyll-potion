module Jekyll::Potion
  class NavigationProcessor < Processor
    NAVIGATION_KEY = "navigation"
    DEPTH_ORDER = "depth_order"

    def initialize(config)
      super
      @navigation_templates = {
        :navigation => config.load_processor_template("navigation"),
        :navigation_page => config.load_processor_template("navigation::page")
      }
    end

    def site_post_read(site)
      page_map = {}
      potion_map = {}

      config.markdown_pages.each { |page|
        def page.depth_order
          self.data[DEPTH_ORDER] ||= 99999999
        end

        page_map[page.url] = page
        potion_map[page.url] = PagePotion.new(config, page, @navigation_templates[:navigation_page])
      }

      potion_map.values.each { |potion| potion.parent = potion_map[potion.parent_path] }

      potion_map.values.group_by { |potion| potion.parent_path }.to_h
                .each { |parent_path, children|
                  potion_map[parent_path].children = children.sort_by { |potion| potion.page.depth_order } if potion_map.has_key?(parent_path)
                }

      root_potions = potion_map.values.select { |potion| potion.parent_path == "" }
                               .sort_by { |potion| potion.page.depth_order }

      order = 0
      root_potions.each { |potion| order = potion.set_order(order) }

      sorted_potions = potion_map.values.sort_by { |potion| potion.order }

      sorted_potions[1..sorted_potions.size].each_with_index { |potion, index|
        potion.before = sorted_potions[index]
      }

      sorted_potions[0..sorted_potions.size - 2].each_with_index { |potion, index|
        potion.after = sorted_potions[index + 1]
      }

      sorted_potions.each { |potion|
        potion.page.data[Config::POTION_KEY] = potion
        logger.trace("#{potion.page.name}##{potion.order} initialize navigation")
      }

      config.make_site_data(
        NAVIGATION_KEY,
        PagePotion.render_for_navigation(@navigation_templates[:navigation], root_potions)
      )

      config.make_site_data(
        Config::ALL_PAGES_KEY,
        sorted_potions.map { |potion| [potion.page.url, potion] }.to_h
      )
    end
  end
end
