module Jekyll::Potion
  class AlertsTag < Liquid::Block
    include PotionTag

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("style")
    end

    def render(page_context)
      render_from_custom_context(
        page_context,
        ->(context, converter) do
          context["alert_style"] = params["style"]
          context["alert_body"] = converter.convert(super)
        end
      )
    end
  end
end

Liquid::Template.register_tag("alerts", Jekyll::Potion::AlertsTag)