module Jekyll::Potion
  class DataPage < Jekyll::Page
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir = dir
      @name = name
      self.process(@name)
      self.data ||= {}
      # self.data["layout"] = "default"
      # self.data["title"] = data
    end
  end
end