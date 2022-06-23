module Jekyll::Potion
  class PagePotion < Liquid::Drop
    attr_accessor :parent_path
    attr_accessor :page
    attr_accessor :parent
    attr_accessor :children
    attr_accessor :order
    attr_accessor :before
    attr_accessor :after
    attr_accessor :empty
    attr_accessor :pagination

    def initialize(site_potion, page, template)
      @baseurl = site_potion.baseurl

      if page.url == "/"
        @parent_path = ""
      else
        @parent_path = page.url.sub(/.*\K\/#{page.basename}/, "")
      end

      @page = page
      @children = []

      @template = template
    end

    def set_order(order)
      @order = order

      order += 1

      if has_child?
        @children.each { |potion| order = potion.set_order(order) }
      end

      order
    end

    def url
      "#{@baseurl}#{@page.url}"
    end

    def has_child?
      !@children.empty?
    end

    def has_before?
      !@before.nil?
    end

    def has_after?
      !@after.nil?
    end

    def empty_content?
      @page.content.strip.empty?
    end

    def render_for_navigation
      @template.render(self)
    end

    def render_for_empty(template)
      @empty = template.render(self)
    end

    def render_for_pagination(template)
      @pagination = template.render(self)
    end

    def self.render_for_navigation(template, potions)
      template.render({ "potions" => potions })
    end
  end
end