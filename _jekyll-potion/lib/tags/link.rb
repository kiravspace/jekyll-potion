module Jekyll::Potion
  class LinkTag < Liquid::Tag
    require "net/http"
    require "nokogiri"

    include PotionTag

    HTTP_SCHEME = %r!http(s)?://!im.freeze

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("url")
    end

    def render(page_context)
      render_from_custom_context(
        page_context,
        ->(context, _) do
          if params["url"] =~ HTTP_SCHEME
            begin
              res = Net::HTTP.get_response URI(params["url"])
              raise res.body unless res.is_a?(Net::HTTPSuccess)
              html = Nokogiri::HTML.parse(res.body)
              context["link_title"] = html.title
              context["link_description"] = html.at("meta[name='description']")["content"] unless html.at("meta[name='description']").nil?
              context["link_url"] = params["url"]
            rescue StandardError => msg
              puts "#{params["url"]} is break."
              context["link_title"] = params["url"]
              context["link_url"] = params["url"]
            end
          else
            potion = context["site"].data[Config::ALL_PAGES_KEY][params["url"]]

            unless potion.nil?
              context["link_title"] = potion.page.data["title"]
              context["link_description"] = potion.page.data["description"]
              context["link_url"] = potion.url
            end
          end

          context["link_title"] = params["caption"] unless params["caption"].nil? || params["caption"].empty?
        end
      )
    end
  end
end

Liquid::Template.register_tag("link", Jekyll::Potion::LinkTag)
