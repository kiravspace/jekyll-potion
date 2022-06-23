module Jekyll::Potion
  class TabsTag < PotionBlock
    def render_tab_content(page_context)
      output = []
      @elements.each { |e| output << e.render(page_context) }
      output.join
    end

    def render(page_context)
      render_from_custom_context(
        page_context,
        ->(context, _) do
          context["tabs_id"] = id

          tabs = []
          @elements.each do |e|
            tabs.push({ "title" => e.title, "tab_id" => e.id })
          end

          context["tabs"] = tabs
          context["tab_contents"] = render_tab_content(page_context)
        end
      )
    end
  end

  class TabContentTag < Liquid::Block
    include PotionBlockElement

    def id_format
      "tab-content-#{options.line_number}"
    end

    def title
      params["title"]
    end

    def render(page_context)
      render_from_custom_context(
        page_context,
        ->(context, converter) do
          context["tab_id"] = id
          context["tab_body"] = converter.convert(@body.render(page_context))
        end
      )
    end
  end
end

Jekyll::Potion::TabsTag.register_tag("content", Jekyll::Potion::TabContentTag)
Liquid::Template.register_tag("tabs", Jekyll::Potion::TabsTag)