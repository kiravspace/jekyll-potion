module Jekyll::Potion
  class FileTag < Liquid::Tag
    include PotionTag

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("src")
    end

    def render(page_context)
      render_from_custom_context(
        page_context,
        ->(context, _) do
          context["file_src"] = File.join(context["site_potion"].baseurl, params["src"])

          if params.has_key?("caption")
            context["file_caption"] = params["caption"]
          else
            context["file_caption"] = params["src"]
          end
        end
      )
    end
  end
end

Liquid::Template.register_tag("file", Jekyll::Potion::FileTag)