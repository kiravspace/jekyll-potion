require "nokogiri"
require "json"

module Jekyll::Potion
  class SearchProcessor < Processor
    def initialize(config)
      super
      @indexes = []
    end

    def page_post_render(page)
      if config.markdown_converter.matches(page.extname)
        html = Nokogiri::HTML.parse(page.output)
        page_potion = config.page_potion(page)

        page_index = {
          "url" => page_potion.url,
          "hashes" => create_indexes(page, html.css("section").css("div.container").css("div.content")),
          "order" => page_potion.order
        }
        @indexes << page_index
        logger.trace(
          "make search index",
          "#{page.name}[#{page_index["hashes"].map { |hash| hash["indexes"].size }.inject(0) { |sum, x| sum + x }}]"
        )
      end
    end

    def site_post_render(site)
      page = DataPage.new(site, site.source, File.join(config.assets_path, "data"), "search.json")
      page.output = JSON.pretty_generate(@indexes)
      site.pages << page
    end

    def create_indexes(page, content)
      hash = ""

      hashed = []

      indexes = []
      indexes << page.data["title"]
      indexes << page.data["description"] unless page.data["description"].nil? || page.data["description"].empty?

      titles = [page.data["title"], "", "", "", "", "", ""]

      content.children.each { |tag|
        if tag.name =~ /h(\d+)/
          unless tag.text.strip.empty?
            hashed << {
              "hash" => "#{hash}",
              "title" => titles.select { |title| !title.empty? }.join(" > "),
              "indexes" => indexes.clone
            }

            current = $1.to_i + 1

            (current..7).each { |i| titles[i] = "" }

            titles[current] = tag.text.strip

            hash = tag["id"]
            indexes.clear
            indexes << tag.text.strip unless tag.text.empty?
          end
        else
          indexes.concat(create_default_index(tag))
        end
      }

      hashed << {
        "hash" => "#{hash}",
        "title" => titles.select { |title| !title.empty? }.join(" > "),
        "indexes" => indexes.clone
      }

      hashed
    end

    def create_default_index(tag)
      indexes = []

      case tag.name
      when "a"
        indexes << tag.text.strip unless tag.text.strip.empty?
      when "p", "blockquote"
        indexes << tag.text.strip unless tag.text.strip.empty?
      when "ul", "ol"
        tag.css("li").each { |li|
          indexes << li.text.strip unless li.text.strip.empty?
        }
      when "table"
        tag.css("thread").css("tr").each { |tr|
          indexes << tr.css("th").map { |td| td.text.strip }.join(" | ")
        }
        tag.css("tbody").css("tr").each { |tr|
          indexes << tr.css("td").map { |td| td.text.strip }.join(" | ")
        }
      when "div"
        indexes.concat(create_div_index(tag))
      when "pre"
        if tag.classes.include?("highlight")
          indexes << tag.css("td.rouge-code").text.strip unless tag.css("td.rouge-code").text.strip.empty?
        end
      when "text", "hr"
        indexes << tag.text.strip unless tag.text.strip.empty?
      else
        logger.warn("undefined search type", tag.name)
      end
      indexes
    end

    def create_div_index(tag)
      indexes = []

      case
      when tag.classes.include?("tabs")
        indexes << tag.css("ul").css("li").map { |li| li.text.strip }.join(" | ")
        tag.css("div.tab_content").each { |tab_content|
          tab_content.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
        }
      when tag.classes.include?("code")
        indexes << tag.css(".code_title").text.strip unless tag.css(".code_title").text.strip.empty?
        indexes << tag.css("td.rouge-code").text.strip unless tag.css("td.rouge-code").text.strip.empty?
      else
        tag.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
      end

      indexes
    end
  end
end
