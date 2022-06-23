module Jekyll::Potion
  class StaticFilesProcessor < Processor
    def site_post_read(site)
      load_static_files(config.assets)
    end

    def load_static_files(base, dir = "")
      Dir.foreach(File.join(base, dir)) { |file_name|
        next if file_name == "." or file_name == ".."

        path = File.join(base, dir, file_name)

        if File.directory?(path)
          load_static_files(base, file_name)
        else
          logger.trace("add static file #{File.join(dir, file_name)}")
          config.add_static_files(base, dir, file_name)
        end
      }
    end
  end
end