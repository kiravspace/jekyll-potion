module Jekyll::Potion
  class RewriteAHrefProcessor < Processor
    A_TAG = %r!<a\s*(?<attributes>.*?)\s*(/)?>!ixm.freeze
    HREF = %r!href\s*="(?<href>[^"]*?)"!im.freeze

    HTTP_SCHEME = %r!\Ahttp(s)?://!im.freeze
    ABSOLUTE_PATH = %r!\A/!im.freeze
    HASH_SCHEME = %r!\A#!im.freeze

    def page_post_render(page)
      if config.markdown_converter.matches(page.extname)
        count = 0
        page.output = page.output.gsub(A_TAG) { |a_tag|
          attributes = Regexp.last_match["attributes"].to_s

          replace_attributes = attributes.gsub(HREF) { |href_attribute|
            href = Regexp.last_match["href"].to_s

            if href !~ HTTP_SCHEME && href !~ ABSOLUTE_PATH && href !~ HASH_SCHEME
              relative_href = href.dup
              relative_href = "./#{relative_href}" unless relative_href.start_with?(".")

              absolute_href = Pathname.new(
                File.join(config.baseurl, File.dirname(page.path), relative_href)
              ).cleanpath.to_s

              count += 1
              href_attribute.gsub(href, absolute_href)
            else
              href_attribute
            end
          }

          a_tag.gsub(attributes, replace_attributes)
        }

        logger.trace("#{page.name} #{count} a tags replace absolute path") if count > 0
      end
    end
  end
end