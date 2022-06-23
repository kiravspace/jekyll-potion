module Jekyll::Potion
  class RewriteImgSrcProcessor < Processor
    IMG_TAG = %r!<img\s*(?<attributes>.*?)\s*(/)?>!ixm.freeze
    SRC = %r!src\s*="(?<src>\.+[^"]*?)"!im.freeze

    HTTP_SCHEME = %r!\Ahttp(s)?://!im.freeze
    ABSOLUTE_PATH = %r!\A/!im.freeze

    RELATIVE_SRC = %r!src\s*="(?<src>\.+[^"]*?)"!im.freeze

    def page_post_render(page)
      if config.markdown_converter.matches(page.extname)
        count = 0

        page.output = page.output.gsub(IMG_TAG) { |img_tag|
          attributes = Regexp.last_match["attributes"].to_s

          replace_attributes = attributes.gsub(SRC) { |src_attribute|
            src = Regexp.last_match["src"].to_s

            if src !~ HTTP_SCHEME && src !~ ABSOLUTE_PATH
              relative_src = src.dup
              relative_src = "./#{relative_src}" unless relative_src.start_with?(".")

              absolute_src = Pathname.new(
                File.join(config.baseurl, File.dirname(page.path), relative_src)
              ).cleanpath.to_s

              count += 1
              src_attribute.gsub(src, absolute_src)
            else
              src_attribute
            end
          }

          img_tag.gsub(attributes, replace_attributes)
        }

        logger.trace("#{page.name} #{count} images replace absolute path") if count > 0
      end
    end
  end
end